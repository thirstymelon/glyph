# Security policy

## Supported versions

Only the latest stable release receives security updates. Development versions (pre-release milestones) are not covered.

| Version | Supported |
|---------|-----------|
| 1.x.x   | Yes |
| < 1.0   | No (development phase) |

## Reporting a vulnerability

If you discover a security vulnerability in Glyph, please report it privately to maintainers@glyph-ada.io. Do not disclose the issue publicly until it has been addressed.

### What to include

- A description of the vulnerability.
- The version(s) affected.
- Steps to reproduce the issue (minimal code example if applicable).
- The potential impact of the vulnerability.
- Any suggested remediation (if known).

### Response timeline

- **Acknowledgement**: Within 48 hours of receipt.
- **Triage**: Within 5 business days (determine severity and impact).
- **Fix**: Within 30 days for critical vulnerabilities; within 90 days for moderate or low severity.
- **Disclosure**: Coordinated public disclosure after the fix is released.

## Disclosure policy

- Security fixes are shipped in the next patch or minor release, depending on severity.
- The release notes for a security fix will include a description of the vulnerability and its impact, credit to the reporter, and the affected versions.
- We request that reporters follow coordinated disclosure: do not publish details of the vulnerability until a fix has been released and users have had reasonable time to update.

## Security expectations for embedded systems

Glyph is an embedded graphics library. Security considerations include:

- **Input validation**: Public API subprograms validate all parameters (bounds checks, format validation).
- **Memory safety**: No heap allocation after initialization prevents memory corruption from allocation failures.
- **Buffer overflow prevention**: All buffer accesses are bounds-checked via Ada's constrained array types.
- **Communication integrity**: Display drivers should verify I2C/SPI transaction completion; however, Glyph does not encrypt display data since physical bus access is assumed to be restricted.
- **Supply chain security**: Alire dependencies are pinned to specific versions and verified through the Alire index.

## Out of scope

The following are outside the scope of Glyph's security policy:

- Vulnerabilities in the GNAT compiler or Ada runtime.
- Vulnerabilities in board-specific HAL implementations not part of the core library.
- Physical attacks on the display bus (e.g., I2C snooping with physical access).
- Denial-of-service through excessive frame rate (applications control frame timing).

## Contact

**Email**: maintainers@glyph-ada.io

**PGP key**: Available at [https://glyph-ada.io/security/pgp-key.asc](https://glyph-ada.io/security/pgp-key.asc) (placeholder).
