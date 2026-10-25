<!--
SPDX-FileCopyrightText: 2026 Philip McColl
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Contributing to Little Rascal Smart Phone

Thanks for your interest in improving this project! Please read this before
opening a pull request.

## Licensing of contributions (inbound = outbound)

By submitting a contribution, you agree that it is licensed under the same
license as the files it adds to or modifies:

| Where | License |
|-------|---------|
| `scripts/` (code) | GPL-3.0-or-later |
| `README.md`, `docs/` and images | CC BY-SA 4.0 |

You keep the copyright of your contribution. No copyright assignment is required.

## Developer Certificate of Origin (DCO)

Every commit must be signed off:

```bash
git commit -s -m "Your message"
```

This adds a `Signed-off-by: Your Name <your@email>` line. By signing off you
certify the [Developer Certificate of Origin 1.1](https://developercertificate.org/):
that you wrote the change, or otherwise have the right to submit it under the
project's licenses.

## Third-party material

- Do not submit code, images or text you did not create unless its license is
  compatible with the table above.
- Keep all original copyright and license notices, and say where it came from.
- Clearly mark any modifications you make to third-party files.

## Before opening a pull request

- Test your changes on a real Raspberry Pi 4.
- Run `bash -n scripts/setup.sh` to check the script syntax.
- Add an SPDX header (copyright + license) to every new file.
