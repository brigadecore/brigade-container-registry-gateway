FROM --platform=$BUILDPLATFORM brigadecore/go-tools:v0.8.0 as builder

ARG VERSION
ARG COMMIT
ARG TARGETOS
ARG TARGETARCH
ENV CGO_ENABLED=0

WORKDIR /src
COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download
COPY . .

RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build \
  -o bin/dockerhub-gateway \
  -ldflags "-w -X github.com/brigadecore/brigade-foundations/version.version=$VERSION -X github.com/brigadecore/brigade-foundations/version.commit=$COMMIT" \
  .

FROM gcr.io/distroless/static:nonroot as final

COPY --from=builder /src/bin/ /brigade-dockerhub-gateway/bin/

ENTRYPOINT ["/brigade-dockerhub-gateway/bin/dockerhub-gateway"]
