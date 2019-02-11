FROM node:alpine AS assetbuilder
WORKDIR /app
COPY package*.json ./
COPY gulpfile.js ./
COPY assets/ ./assets/
RUN npm install && NODE_ENV=production ./node_modules/gulp/bin/gulp.js

FROM golang:latest AS binarybuilder
WORKDIR /go/src/github.com/usefathom/fathom
COPY . /go/src/github.com/usefathom/fathom
COPY --from=assetbuilder /app/assets/build ./assets/build
RUN make docker

FROM alpine:latest
EXPOSE 8080
RUN apk add --update --no-cache bash ca-certificates
WORKDIR /app
COPY --from=binarybuilder /go/src/github.com/usefathom/fathom/fathom .
CMD ["./fathom", "server"]
