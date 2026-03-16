# Changelog

## [0.10.4](https://github.com/claude-contrib/claude-sandbox/compare/v0.10.3...v0.10.4) (2026-03-16)


### Bug Fixes

* move git environment resolution earlier in docker setup ([078da34](https://github.com/claude-contrib/claude-sandbox/commit/078da340cb108e5a37b148012f8a968394862912))

## [0.10.3](https://github.com/claude-contrib/claude-sandbox/compare/v0.10.2...v0.10.3) (2026-03-16)


### Bug Fixes

* add required hookEventName to SessionStart hook output ([a161e4b](https://github.com/claude-contrib/claude-sandbox/commit/a161e4bb58a77eb8618a45bc633291052ecc99a8))
* normalize indentation in docker exec script ([9e24fd6](https://github.com/claude-contrib/claude-sandbox/commit/9e24fd665adf884142506adbd256f3a1c6be7697))

## [0.10.2](https://github.com/claude-contrib/claude-sandbox/compare/v0.10.1...v0.10.2) (2026-03-16)


### Bug Fixes

* **docker:** use hardcoded user and home path in system prompt ([53bb3dd](https://github.com/claude-contrib/claude-sandbox/commit/53bb3dd77873b26ea3e8d0079cead3d4d1e2045a))

## [0.10.1](https://github.com/claude-contrib/claude-sandbox/compare/v0.10.0...v0.10.1) (2026-03-16)


### Bug Fixes

* concatenate multiple --append-system-prompt flags into one ([4433a75](https://github.com/claude-contrib/claude-sandbox/commit/4433a75aaa76ea462fbcb0258b7c7185f3063dc6))
* defer --help handling to sandbox wrapper ([12c1af7](https://github.com/claude-contrib/claude-sandbox/commit/12c1af7c788a03e00be6b08d2cd28ba8c48ec786))
* replace --help flag with --sandbox-help for wrapper ([32182fb](https://github.com/claude-contrib/claude-sandbox/commit/32182fb18d26df194e36d1982d5e097545fb32ff))
* resolve git config from working directory ([66746ae](https://github.com/claude-contrib/claude-sandbox/commit/66746ae92b066c54b1a136280cafad3705ca57d5))

## [0.10.0](https://github.com/claude-contrib/claude-sandbox/compare/v0.9.1...v0.10.0) (2026-03-16)


### Features

* **docker:** add system prompt context to claude invocations ([bc051d6](https://github.com/claude-contrib/claude-sandbox/commit/bc051d6518a1d4a508dc6d2a7d849ddc140533ba))

## [0.9.1](https://github.com/claude-contrib/claude-sandbox/compare/v0.9.0...v0.9.1) (2026-03-16)


### Bug Fixes

* **docker:** mount known_hosts to claude user's SSH directory ([b280a2e](https://github.com/claude-contrib/claude-sandbox/commit/b280a2e01c9fe62e50d898f8454ef234e07101bf))

## [0.9.0](https://github.com/claude-contrib/claude-sandbox/compare/v0.8.1...v0.9.0) (2026-03-16)


### Features

* **docker:** forward host git config and identity into sandbox container ([03268c9](https://github.com/claude-contrib/claude-sandbox/commit/03268c91826d3733bdc6784d1dc4c7174065c63b))
* **docker:** mount host paths for shared settings and session resumption ([e22e687](https://github.com/claude-contrib/claude-sandbox/commit/e22e687a74fc11d930bcc5d58298d405913f9901))

## [0.8.1](https://github.com/claude-contrib/claude-sandbox/compare/v0.8.0...v0.8.1) (2026-03-16)


### Bug Fixes

* **test:** use -e instead of -S for SSH_AUTH_SOCK check ([1acbf72](https://github.com/claude-contrib/claude-sandbox/commit/1acbf72b246843de50642620465f207eb3f01f72))

## [0.8.0](https://github.com/claude-contrib/claude-sandbox/compare/v0.7.0...v0.8.0) (2026-03-16)


### Features

* **docker:** replace hardcoded SSH group ID with dynamic container lookup ([4188572](https://github.com/claude-contrib/claude-sandbox/commit/41885725e26c137a3c502988afbe27cc0d0b9d0d))

## [0.7.0](https://github.com/claude-contrib/claude-sandbox/compare/v0.6.1...v0.7.0) (2026-03-16)


### Features

* **debug:** add DEBUG environment variable support ([4ca800c](https://github.com/claude-contrib/claude-sandbox/commit/4ca800cf4fbef34274b1ed783b5452510ceb1e06))
* **docker:** add user group mapping support ([44ca6d9](https://github.com/claude-contrib/claude-sandbox/commit/44ca6d933397e002b2dd0a0a644bd3501e990a84))
* **docker:** improve ssh and ssl certificate handling ([ab3178a](https://github.com/claude-contrib/claude-sandbox/commit/ab3178a62064e9857f02f604db3f0d1f120e6898))
* use nixos/nix docker image ([9092924](https://github.com/claude-contrib/claude-sandbox/commit/909292433dc0e5a939f36e18f32ce8fa8f2b427a))


### Bug Fixes

* **docker:** restore ghcr image reference ([28fbb69](https://github.com/claude-contrib/claude-sandbox/commit/28fbb6971c685f1c209b28449e472c7b0b69f6a6))

## [0.6.1](https://github.com/claude-contrib/claude-sandbox/compare/v0.6.0...v0.6.1) (2026-03-16)


### Bug Fixes

* emit clean error when Docker daemon is unreachable in sandbox mode ([ec9cb08](https://github.com/claude-contrib/claude-sandbox/commit/ec9cb0838a279f656053d5be070c2ba116fd29aa))

## [0.6.0](https://github.com/claude-contrib/claude-sandbox/compare/v0.5.0...v0.6.0) (2026-03-16)


### Features

* add CLAUDE_SANDBOX env var to enable sandbox mode without a flag ([54dc609](https://github.com/claude-contrib/claude-sandbox/commit/54dc609de56d53e53fad20615e77c230eaee4ad3))
* forward host environment variables via claude-sandbox.env ([aacc08e](https://github.com/claude-contrib/claude-sandbox/commit/aacc08e4e550192261ba179947572c5756eb2fb1))
* merge host settings.docker.json over baked-in settings at startup ([1229480](https://github.com/claude-contrib/claude-sandbox/commit/12294802a42dfd7a8b7888670981b589dfae93ca))


### Bug Fixes

* **tests:** update tests to match _usage→_show_help rename and GH_TOKEN refactor ([dd782dd](https://github.com/claude-contrib/claude-sandbox/commit/dd782ddc6fcacec67b4b6aa0086e030930d3d45f))

## [0.5.0](https://github.com/claude-contrib/claude-sandbox/compare/v0.4.2...v0.5.0) (2026-03-15)


### Features

* migrate to nixos/nix base image with claude-code-nix ([1163a63](https://github.com/claude-contrib/claude-sandbox/commit/1163a637301debd29f1282085fbdea0785407c44))


### Bug Fixes

* reduce image size with nix store gc, optimise, and cache cleanup ([ff0606b](https://github.com/claude-contrib/claude-sandbox/commit/ff0606bfc8402f8e3ba67a505499cc009236c437))
* resolve quoted glob, broken working dir mapping, and fragile stdin handling ([9cfab7c](https://github.com/claude-contrib/claude-sandbox/commit/9cfab7c9129a6b967f243cb994a6b69b45872bd7))
* restore pipe+interactive support with /dev/tty reconnect ([5bb23cf](https://github.com/claude-contrib/claude-sandbox/commit/5bb23cf17983d7ba0acd13b2636ce9a64da63382))
* three-way stdin handling for pipe+tty, pipe-only, and interactive ([5b5dc4e](https://github.com/claude-contrib/claude-sandbox/commit/5b5dc4ec7412dcc2070469135d62ae180dea51a9))

## [0.4.2](https://github.com/claude-contrib/claude-sandbox/compare/v0.4.1...v0.4.2) (2026-03-15)


### Bug Fixes

* add locale and terminal ENV vars for proper Unicode and color support ([7671318](https://github.com/claude-contrib/claude-sandbox/commit/76713188f23de883477b72792029d260bd97489f))
* persist ~/.cache volume to avoid repeated nix downloads ([b3ece88](https://github.com/claude-contrib/claude-sandbox/commit/b3ece88c997eda82c23e1bf3f896b4c1f00b0187))

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
