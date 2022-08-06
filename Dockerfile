FROM alpine as poseidon-builder

RUN apk --no-cache add git maven
WORKDIR /build/

RUN git clone https://github.com/RhysB/Project-Poseidon.git --depth=1 "Poseidon"

WORKDIR /build/Poseidon

RUN mvn -B package

FROM gcr.io/distroless/java11-debian11:nonroot

WORKDIR /runtime/
COPY --chown=nonroot:nonroot --from=poseidon-builder /build/Poseidon/target/project-posiden*.jar server.jar

USER nonroot:nonroot

WORKDIR /server/
ENTRYPOINT [ "java", "-Xms5g", "-Xmx5g", "-XX:+UseG1GC", "-XX:+ParallelRefProcEnabled", "-XX:MaxGCPauseMillis=200", "-XX:+UnlockExperimentalVMOptions", "-XX:+DisableExplicitGC", "-XX:+AlwaysPreTouch", "-XX:G1NewSizePercent=30", "-XX:G1MaxNewSizePercent=40", "-XX:G1HeapRegionSize=8M", "-XX:G1ReservePercent=20", "-XX:G1HeapWastePercent=5", "-XX:G1MixedGCCountTarget=4", "-XX:InitiatingHeapOccupancyPercent=15", "-XX:G1MixedGCLiveThresholdPercent=90", "-XX:G1RSetUpdatingPauseTimePercent=5", "-XX:SurvivorRatio=32", "-XX:+PerfDisableSharedMem", "-XX:MaxTenuringThreshold=1", "-jar", "/runtime/server.jar" ]
