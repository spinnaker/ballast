FROM openjdk:11

COPY . /apps/ballast

WORKDIR /apps/ballast

RUN ./gradlew build compileTestKotlin -x test

CMD ["./ballast.sh"]
