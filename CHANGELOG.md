# Changelog

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
