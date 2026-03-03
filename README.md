# qlty-glab

This repository provides a base Docker image for GitLab CI jobs that need to:

1. Run the `qlty` command.
2. Convert the generated SARIF report into a GitLab-compatible report format.

The image is based on `ghcr.io/qltysh/qlty` and preinstalls:

- `curl`
- `jq`
- `build-essential`
- `sarif-converter`

## Docker Image

Build the image locally:

```bash
docker build -t qlty-glab:latest .
```

## Usage

Use this image in a GitLab pipeline and publish a GitLab code quality report:

```yaml
qlty-check:
  stage: test
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
  image:
    name: registry.example.com/group/project/qlty-gitlab-base:latest
    entrypoint: [""]
  script:
    - qlty init --no || echo "Already initialized"
    - qlty check --all
    - qlty check --all --sarif --no-error --no-fail > qlty_report.sarif
    - jq '(.runs[]?.tool?.driver?.releaseDateUtc) |= (if test("T") then . else . + "T00:00:00Z" end)' qlty_report.sarif > qlty_report_fixed.sarif
    - sarif-converter --type codequality qlty_report_fixed.sarif gl-code-quality-report.json
    - rm qlty_report.sarif qlty_report_fixed.sarif
  artifacts:
    reports:
      codequality: gl-code-quality-report.json
    when: always
    expire_in: 1 month
    paths:
      - gl-code-quality-report.json
```

## Notes

- Keep `entrypoint: [""]` in GitLab CI so `script` runs in a shell context.
- The `jq` line normalizes `releaseDateUtc` to a full ISO timestamp before conversion.
- If converter arguments change in future releases, run `sarif-converter --help` and adjust `.gitlab-ci.yml` accordingly.
