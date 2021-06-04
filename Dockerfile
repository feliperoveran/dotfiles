FROM ubuntu:20.04

RUN apt-get update && apt-get install -y rake curl git jq sudo wget vim tmux
