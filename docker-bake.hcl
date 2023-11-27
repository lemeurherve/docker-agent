group "linux" {
  targets = [
    "alpine_jdk11",
    "alpine_jdk17",
    "alpine_jdk21",
    "archlinux_jdk11",
    "debian_jdk11",
    "debian_jdk17",
    "debian_jdk21",
    "debian_jdk21_preview"
  ]
}

group "linux-agent-only" {
  targets = [
    "agent_alpine_jdk11",
    "agent_alpine_jdk17",
    "agent_alpine_jdk21",
    "archlinux_jdk11",
    "agent_debian_jdk11",
    "agent_debian_jdk17",
    "agent_debian_jdk21",
    "agent_debian_jdk21_preview"
  ]
}

group "linux-inbound-agent-only" {
  targets = [
    "inbound-agent_alpine_jdk11",
    "inbound-agent_alpine_jdk17",
    "inbound-agent_alpine_jdk21",
    "inbound-agent_debian_jdk11",
    "inbound-agent_debian_jdk17",
    "inbound-agent_debian_jdk21",
    "inbound-agent_debian_jdk21_preview"
  ]
}

group "linux-arm64" {
  targets = [
    "debian_jdk11",
    "debian_jdk17",
    "debian_jdk21",
    "alpine_jdk21",
  ]
}

group "linux-arm32" {
  targets = [
    "debian_jdk11",
    "debian_jdk17",
    "debian_jdk21_preview"
  ]
}

group "linux-s390x" {
  targets = [
    "debian_jdk11",
    "debian_jdk21_preview"
  ]
}

group "linux-ppc64le" {
  targets = [
    "debian_jdk11",
    "debian_jdk17",
    "debian_jdk21_preview"
  ]
}

variable "REMOTING_VERSION" {
  default = "3192.v713e3b_039fb_e"
}

variable "REGISTRY" {
  default = "docker.io"
}

variable "REGISTRY_ORG" {
  default = "jenkins"
}

variable "REGISTRY_REPO_AGENT" {
  default = "agent"
}

variable "REGISTRY_REPO_INBOUND_AGENT" {
  default = "inbound-agent"
}

variable "BUILD_NUMBER" {
  default = "1"
}

variable "ON_TAG" {
  default = "false"
}

variable "ALPINE_FULL_TAG" {
  default = "3.18.4"
}

variable "ALPINE_SHORT_TAG" {
  default = regex_replace(ALPINE_FULL_TAG, "\\.\\d+$", "")
}

variable "DEBIAN_RELEASE" {
  default = "bookworm-20230904"
}

variable "JAVA11_VERSION" {
  default = "11.0.20.1_1"
}

variable "JAVA17_VERSION" {
  default = "17.0.8.1_1"
}

variable "JAVA21_VERSION" {
  default = "21_35"
}

variable "JAVA21_PREVIEW_VERSION" {
  default = "21.0.1+12"
}

target "archlinux_jdk11" {
  dockerfile = "archlinux/Dockerfile"
  context    = "."
  args = {
    JAVA_VERSION = JAVA11_VERSION
    VERSION      = REMOTING_VERSION
  }
  tags = [
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${REGISTRY_REPO_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}-archlinux" : "",
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${REGISTRY_REPO_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}-archlinux-jdk11" : "",
    "${REGISTRY}/${REGISTRY_ORG}/${REGISTRY_REPO_AGENT}:archlinux",
    "${REGISTRY}/${REGISTRY_ORG}/${REGISTRY_REPO_AGENT}:latest-archlinux",
    "${REGISTRY}/${REGISTRY_ORG}/${REGISTRY_REPO_AGENT}:archlinux-jdk11",
    "${REGISTRY}/${REGISTRY_ORG}/${REGISTRY_REPO_AGENT}:latest-archlinux-jdk11",
  ]
  platforms = ["linux/amd64"]
}

target "alpine_jdk11" {
  matrix = {
    type = ["agent", "inbound-agent"]
  }
  name = "${type}_alpine_jdk11"
  target = type
  dockerfile = "alpine/Dockerfile"
  context    = "."
  args = {
    ALPINE_TAG   = ALPINE_FULL_TAG
    JAVA_VERSION = JAVA11_VERSION
    VERSION      = REMOTING_VERSION
  }
  tags = [
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}-alpine-jdk11" : "",
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}-alpine${ALPINE_SHORT_TAG}-jdk11" : "",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:alpine-jdk11",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:alpine${ALPINE_SHORT_TAG}-jdk11",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-alpine-jdk11",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-alpine${ALPINE_SHORT_TAG}-jdk11",
  ]
  platforms = ["linux/amd64"]
}

target "alpine_jdk17" {
  matrix = {
    type = ["agent", "inbound-agent"]
  }
  name = "${type}_alpine_jdk17"
  target = type
  dockerfile = "alpine/Dockerfile"
  context    = "."
  args = {
    ALPINE_TAG   = ALPINE_FULL_TAG
    JAVA_VERSION = JAVA17_VERSION
    VERSION      = REMOTING_VERSION
  }
  tags = [
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}-alpine" : "",
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}-alpine${ALPINE_SHORT_TAG}" : "",
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}-alpine-jdk17" : "",
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}-alpine${ALPINE_SHORT_TAG}-jdk17" : "",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:alpine",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:alpine${ALPINE_SHORT_TAG}",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:alpine-jdk17",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:alpine${ALPINE_SHORT_TAG}-jdk17",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-alpine",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-alpine${ALPINE_SHORT_TAG}",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-alpine-jdk17",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-alpine${ALPINE_SHORT_TAG}-jdk17",
  ]
  platforms = ["linux/amd64"]
}

target "alpine_jdk21" {
  matrix = {
    type = ["agent", "inbound-agent"]
  }
  name = "${type}_alpine_jdk21"
  target = type
  dockerfile = "alpine/Dockerfile"
  context    = "."
  args = {
    ALPINE_TAG   = ALPINE_FULL_TAG
    JAVA_VERSION = JAVA21_VERSION
    VERSION      = REMOTING_VERSION
  }
  tags = [
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}-alpine-jdk21" : "",
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}-alpine${ALPINE_SHORT_TAG}-jdk21" : "",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:alpine-jdk21",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:alpine${ALPINE_SHORT_TAG}-jdk21",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-alpine-jdk21",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-alpine${ALPINE_SHORT_TAG}-jdk21",
  ]
  platforms = ["linux/amd64", "linux/arm64"]
}

target "debian_jdk11" {
  matrix = {
    type = ["agent", "inbound-agent"]
  }
  name = "${type}_debian_jdk11"
  target = type
  dockerfile = "debian/Dockerfile"
  context    = "."
  args = {
    JAVA_VERSION   = JAVA11_VERSION
    VERSION        = REMOTING_VERSION
    DEBIAN_RELEASE = DEBIAN_RELEASE
  }
  tags = [
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}-jdk11" : "",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:bookworm-jdk11",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:jdk11",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-bookworm-jdk11",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-jdk11",
  ]
  platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/s390x", "linux/ppc64le"]
}

target "debian_jdk17" {
  matrix = {
    type = ["agent", "inbound-agent"]
  }
  name = "${type}_debian_jdk17"
  target = type
  dockerfile = "debian/Dockerfile"
  context    = "."
  args = {
    JAVA_VERSION   = JAVA17_VERSION
    VERSION        = REMOTING_VERSION
    DEBIAN_RELEASE = DEBIAN_RELEASE
  }
  tags = [
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}" : "",
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}-jdk17" : "",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:bookworm-jdk17",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:jdk17",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-bookworm",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-bookworm-jdk17",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-jdk17",
  ]
  platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/ppc64le"]
}

target "debian_jdk21" {
  matrix = {
    type = ["agent", "inbound-agent"]
  }
  name = "${type}_debian_jdk21"
  target = type
  dockerfile = "debian/Dockerfile"
  context    = "."
  args = {
    JAVA_VERSION   = JAVA21_VERSION
    VERSION        = REMOTING_VERSION
    DEBIAN_RELEASE = DEBIAN_RELEASE
  }
  tags = [
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${type == "agent"}:${REMOTING_VERSION}-${BUILD_NUMBER}-jdk21" : "",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:bookworm-jdk21",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:jdk21",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-bookworm-jdk21",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-jdk21",
  ]
  platforms = ["linux/amd64", "linux/arm64"]
}

target "debian_jdk21_preview" {
  matrix = {
    type = ["agent", "inbound-agent"]
  }
  name = "${type}_debian_jdk21_preview"
  target = type
  dockerfile = "debian/preview/Dockerfile"
  context    = "."
  args = {
    JAVA_VERSION   = JAVA21_PREVIEW_VERSION
    VERSION        = REMOTING_VERSION
    DEBIAN_RELEASE = DEBIAN_RELEASE
  }
  tags = [
    equal(ON_TAG, "true") ? "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:${REMOTING_VERSION}-${BUILD_NUMBER}-jdk21-preview" : "",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:bookworm-jdk21-preview",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:jdk21-preview",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-bookworm-jdk21-preview",
    "${REGISTRY}/${REGISTRY_ORG}/${type == "agent" ? REGISTRY_REPO_AGENT : REGISTRY_REPO_INBOUND_AGENT}:latest-jdk21-preview",
  ]
  platforms = ["linux/ppc64le", "linux/s390x", "linux/arm/v7"]
}
