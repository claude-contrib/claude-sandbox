# Changelog

## [0.4.1](https://github.com/claude-contrib/claude-sandbox/compare/v0.4.0...v0.4.1) (2026-03-15)


### Bug Fixes

* clarify docker image pull message ([f042fb7](https://github.com/claude-contrib/claude-sandbox/commit/f042fb72704e678e930da295d2cb3e406c87dd5c))
* update claude-status symlink after .sh extension removal ([8d0176d](https://github.com/claude-contrib/claude-sandbox/commit/8d0176df469d219f018746c9c51b3695de54616d))

## [0.4.0](https://github.com/claude-contrib/claude-sandbox/compare/v0.3.1...v0.4.0) (2026-03-15)


### Features

* add --help flag, image pre-pull with spinner, and gum integration ([123b75b](https://github.com/claude-contrib/claude-sandbox/commit/123b75b02360f7a553518a19e3b212b6428de886))
* install claude-status in sandbox container ([ae63245](https://github.com/claude-contrib/claude-sandbox/commit/ae6324563608b4cdafaa6d5d77a088f950d5ed39))


### Bug Fixes

* add nix bin to PATH in Dockerfile ([d4850e1](https://github.com/claude-contrib/claude-sandbox/commit/d4850e19bef3cf021fe3e0b6c7314ec07fa98d92))
* alias GITHUB_TOKEN to GH_TOKEN in sandbox mode ([35a695c](https://github.com/claude-contrib/claude-sandbox/commit/35a695c7ffc46e892341a64ebb3efcae9b853abc))
* consolidate GH_TOKEN/GITHUB_TOKEN in --help output ([13d47c0](https://github.com/claude-contrib/claude-sandbox/commit/13d47c0a9911a5e5b5ed771c95111545aac95984))
* uppercase log messages and drop sandbox: prefix ([515ced3](https://github.com/claude-contrib/claude-sandbox/commit/515ced367322e502ee21fb326f999a3ae2265c5f))

## [0.3.1](https://github.com/claude-contrib/claude-sandbox/compare/v0.3.0...v0.3.1) (2026-03-15)


### Bug Fixes

* disable Nix seccomp BPF filtering for arm64 QEMU compatibility ([a815080](https://github.com/claude-contrib/claude-sandbox/commit/a8150803a73d9aa10aeff08d69eaeb0cc7a380f9))

## [0.3.0](https://github.com/claude-contrib/claude-sandbox/compare/v0.2.2...v0.3.0) (2026-03-15)


### Features

* auto-join devcontainer Docker network in sandbox mode ([3b717c4](https://github.com/claude-contrib/claude-sandbox/commit/3b717c44eda215d4f6b8424275ac24736839b49f))


### Bug Fixes

* add linux/arm64 platform to Docker image build ([b199743](https://github.com/claude-contrib/claude-sandbox/commit/b199743e5e065a3028252bb772dc21ff2f0d04f8))

## [0.2.2](https://github.com/claude-contrib/claude-sandbox/compare/v0.2.1...v0.2.2) (2026-03-15)


### Bug Fixes

* **ci:** supply explicit tag value to metadata-action to fix empty tags on push-to-main ([1ec7c96](https://github.com/claude-contrib/claude-sandbox/commit/1ec7c96a244fa62f8b336659564c4d15533136f6))

## [0.2.1](https://github.com/claude-contrib/claude-sandbox/compare/v0.2.0...v0.2.1) (2026-03-15)


### Bug Fixes

* fallback to GITHUB_TOKEN when GH_TOKEN is unset ([83d0806](https://github.com/claude-contrib/claude-sandbox/commit/83d0806acf9791065353f59c2090fc27b2f686e0))
* remove unused claude-nix.sh invocation in docker run ([492c75f](https://github.com/claude-contrib/claude-sandbox/commit/492c75ff91fcef06e36ba0530d23ba7862325eb4))

## [0.2.0](https://github.com/claude-contrib/claude-sandbox/compare/v0.1.0...v0.2.0) (2026-03-14)


### Features

* add claude wrapper with host forwarding and sandbox mode ([f4351d9](https://github.com/claude-contrib/claude-sandbox/commit/f4351d938d4a4b1f35bd3bd907c38e7113e24e12))
* add Docker sandbox with Nix flake support ([491cbf8](https://github.com/claude-contrib/claude-sandbox/commit/491cbf87c433a40cf78e93bfd945e5224557cf2d))
* add SSH agent, GitHub CLI, and GH_TOKEN support ([1c49cf2](https://github.com/claude-contrib/claude-sandbox/commit/1c49cf261352067ef70ccf9e20b43e543453cb8b))


### Bug Fixes

* conditionally mount SSH agent and pass GH_TOKEN ([6ec2a52](https://github.com/claude-contrib/claude-sandbox/commit/6ec2a52be57a905d359fb1bc87d8fc404a4cd4e3))
* use proper GHCR image name in docker-compose ([9e44720](https://github.com/claude-contrib/claude-sandbox/commit/9e44720bd8ecddfb86962535b2d3ba9fdd4a394a))
