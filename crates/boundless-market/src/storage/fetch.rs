// Copyright 2025 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//! An implementation of URL fetching that supports the common URL types seen on Boundless.

use crate::util::is_dev_mode;
use anyhow::{bail, ensure};
use bytes::Bytes;
use url::Url;

/// Rewrites a pinata gateway URL to a more accessible IPFS gateway.
pub fn rewrite_ipfs_gateway(url: &str) -> String {
    if url.starts_with("https://gateway.pinata.cloud/ipfs/") {
        let cid = url.trim_start_matches("https://gateway.pinata.cloud/ipfs/");
        // Use dweb.link IPFS gateway which is generally more reliable
        format!("https://dweb.link/ipfs/{}", cid)
    } else {
        url.to_string()
    }
}

/// Fetches a URL with a retry mechanism that tries multiple IPFS gateways.
pub async fn fetch_url_with_retry(original_url: &str) -> anyhow::Result<Bytes> {
    let gateways = [
        "https://dweb.link/ipfs/",
        "https://ipfs.io/ipfs/",
        "https://gateway.pinata.cloud/ipfs/",
        "https://cloudflare-ipfs.com/ipfs/",
    ];

    // Extract CID from any IPFS URL
    let cid = if let Some(pos) = original_url.find("/ipfs/") {
        &original_url[pos + 6..]
    } else {
        // Not an IPFS URL, just try to fetch it directly
        return fetch_url(original_url).await;
    };

    for gateway in gateways {
        let url = format!("{}{}", gateway, cid);
        match fetch_url(&url).await {
            Ok(data) => return Ok(data),
            Err(e) => {
                tracing::warn!("Failed to fetch from {}: {}", url, e);
            }
        }
    }

    anyhow::bail!("Failed to fetch from all IPFS gateways")
}

/// Fetches the content of a URL.
/// Supported URL schemes are `http`, `https`, and `file`.
pub async fn fetch_url(url_str: impl AsRef<str>) -> anyhow::Result<Bytes> {
    tracing::debug!("Fetching URL: {}", url_str.as_ref());
    let url = Url::parse(url_str.as_ref())?;

    match url.scheme() {
        "http" | "https" => fetch_http(&url).await,
        "file" => {
            ensure!(is_dev_mode(), "file fetch is only enabled when RISC0_DEV_MODE is enabled");
            fetch_file(&url).await
        }
        _ => bail!("unsupported URL scheme: {}", url.scheme()),
    }
}

async fn fetch_http(url: &Url) -> anyhow::Result<Bytes> {
    let response = reqwest::get(url.as_str()).await?;
    let status = response.status();
    if !status.is_success() {
        bail!("HTTP request failed with status: {}", status);
    }

    Ok(response.bytes().await?)
}

async fn fetch_file(url: &Url) -> anyhow::Result<Bytes> {
    let path = std::path::Path::new(url.path());
    let data = tokio::fs::read(path).await?;
    Ok(data.into())
}
