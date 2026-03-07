# init.sh LAN base.sh selection

## Summary
Add a LAN-preferred download path in `init.sh`. If `http://172.22.90.1:5244/sh/base.sh` is reachable, download and execute that script. Otherwise, keep the existing CN/IPv6-based selection behavior.

## Goals
- Prefer the LAN URL when reachable.
- Preserve existing behavior when the LAN URL is not reachable.
- Keep the script small and readable.

## Non-Goals
- Adding robust retry logic.
- Changing the existing CN/IPv6 detection rules.
- Adding signature checks or integrity verification.

## Design
### Flow
1. Define `script_path` as `$HOME/sh/base.sh`.
2. Preflight check the LAN URL with a short timeout.
3. If reachable, download from the LAN URL and skip other selection logic.
4. If not reachable, run the current country/IPv6/IPv4 detection and select the GitHub or mirror URL as before.
5. `chmod +x` and execute the downloaded script with the original arguments.

### Reachability check
Use `curl` with a short `--max-time` and `--head` to avoid full downloads. The check succeeds when curl returns exit code 0 and the HTTP status is successful. This avoids delays while still quickly preferring LAN when available.

### Error handling
Keep behavior consistent with current script: if download fails, execution will fail naturally. No additional error handling is added in this change.

## Testing
- Manual: With LAN URL reachable, verify `base.sh` is downloaded from LAN and executed.
- Manual: With LAN URL unreachable, verify the existing CN/IPv6 logic is used and the script runs.
- Manual: Verify original arguments are forwarded unchanged.
