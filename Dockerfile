FROM node:18-alpine3.16 AS base

ENV NODE_ENV build

WORKDIR /app

COPY . .

RUN yarn
RUN yarn build

FROM node:18-alpine3.16 AS local

ENV NODE_ENV local

ARG USR
ENV USR $USR
ARG GRP
ENV GRP $GRP

ARG UID
ARG GID

RUN apk add --no-cache shadow sudo && \
  if [ -z "`getent group $GID`" ]; then \
  addgroup -S -g $GID cetacean; \
  else \
  groupmod -n cetacean `getent group $GID | cut -d: -f1`; \
  fi && \
  if [ -z "`getent passwd $UID`" ]; then \
  adduser -S -u $UID -G cetacean -s /bin/sh $USR; \
  else \
  usermod -l $USR -g $GID -d "/home/$USR" -m `getent passwd $UID | cut -d: -f1`; \
  fi && \
  echo "$USR ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/$USR" && \
  chmod 0440 "/etc/sudoers.d/$USR"

WORKDIR /app
# USER appuser

USER appuser

WORKDIR "/home/$USR/app"

COPY --from=base /app/. .

CMD [ "sh", "-c", "yarn start:dev"]