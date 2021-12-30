# Stage 1: Development Base ====================================================
# This stage will contain the minimal dependencies for the rest of the images
# used to build the project:

# Use the official Ruby 3.1.0 alpine image as base:
FROM ruby:3.1.0-alpine AS development-base

# Install the app build system dependency packages:
RUN apk add --no-cache build-base git

# Receive the developer user's UID and USER:
ARG DEVELOPER_UID=1000
ARG DEVELOPER_USERNAME=you

# Replicate the developer user in the development image:
RUN addgroup --gid ${DEVELOPER_UID} ${DEVELOPER_USERNAME} \
 ;  adduser -S -u ${DEVELOPER_UID} \
    -s /bin/ash -g "Developer User,,," ${DEVELOPER_USERNAME}

# Ensure the developer user's home directory and APP_PATH are owned by him/her:
# (A workaround to a side effect of setting WORKDIR before creating the user)
RUN userhome=$(eval echo ~${DEVELOPER_USERNAME}) \
 && chown -R ${DEVELOPER_USERNAME}:${DEVELOPER_USERNAME} $userhome \
 && mkdir -p /workspaces/bootstrap-scss \
 && chown -R ${DEVELOPER_USERNAME}:${DEVELOPER_USERNAME} /workspaces/bootstrap-scss

# Add the library's "bin/" directory to PATH:
ENV PATH=/workspaces/bootstrap-scss/bin:$PATH

# Set the code path as the working directory:
WORKDIR /workspaces/bootstrap-scss

# Change to the developer user:
USER ${DEVELOPER_USERNAME}

# Configure bundler to retry downloads 3 times:
RUN bundle config set --local retry 3

# Configure bundler to use 4 threads to download, build and install:
RUN bundle config set --local jobs 4

# Stage 2: Testing =============================================================
# In this stage we'll complete an image with the minimal dependencies required
# to run the tests in a continuous integration environment.
FROM development-base AS testing

# Copy the project's Gemfile and Gemfile.lock files:
COPY --chown=${DEVELOPER_USERNAME} bootstrap-scss.gemspec Gemfile* /workspaces/bootstrap-scss/

# Copy the project's gem version file
COPY --chown=${DEVELOPER_USERNAME} lib/bootstrap/scss/version.rb /workspaces/bootstrap-scss/lib/bootstrap/scss/

# Configure bundler to exclude the gems from the "development" group when
# installing, so we get the leanest Docker image possible to run tests:
RUN bundle config set --local without development

# Install the project gems, excluding the "development" group:
RUN bundle install

# Stage 3: Development =========================================================
# In this stage we'll add the packages, libraries and tools required in our
# day-to-day development process.
FROM testing AS development

# Change to root user to install the development packages:
USER root

# Install sudo, along with any other tool required at development phase:
RUN apk add --no-cache \
  # Adding bash autocompletion as git without autocomplete is a pain...
  bash-completion \
  # gpg & gpgconf is used to get Git Commit GPG Signatures working inside the
  # VSCode devcontainer:
  gpg \
  gpgconf \
  # Make ssh work in container (still need to figure out how to forward agent):
  openssh-client \
  # Vim will be used to edit files when inside the container (git, etc):
  vim \
  # Sudo will be used to install/configure system stuff if needed during dev:
  sudo

# Receive the developer username - note that ARGS won't persist between stages
# on non-buildkit builds:
ARG DEVELOPER_USERNAME=you

# Add the developer user to the sudoers list:
RUN echo "${DEVELOPER_USERNAME} ALL=(ALL) NOPASSWD:ALL" | tee "/etc/sudoers.d/${DEVELOPER_USERNAME}"

# Change back to the developer user:
USER ${DEVELOPER_USERNAME}

# Persist the ash history between runs
# - See https://code.visualstudio.com/docs/remote/containers-advanced#_persist-bash-history-between-runs
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/command-history/.ash_history" \
 && sudo mkdir /command-history \
 && sudo touch /command-history/.ash_history \
 && sudo chown -R ${DEVELOPER_USERNAME} /command-history \
 && echo $SNIPPET >> "/home/${DEVELOPER_USERNAME}/.profile"

# Create the extensions directories:
RUN mkdir -p \
  /home/${DEVELOPER_USERNAME}/.vscode-server/extensions \
  /home/${DEVELOPER_USERNAME}/.vscode-server-insiders/extensions \
 && chown -R ${DEVELOPER_USERNAME} \
  /home/${DEVELOPER_USERNAME}/.vscode-server \
  /home/${DEVELOPER_USERNAME}/.vscode-server-insiders

# Copy the gems installed in the "testing" stage:
COPY --from=testing /usr/local/bundle /usr/local/bundle
COPY --from=testing /workspaces/bootstrap-scss/ /workspaces/bootstrap-scss/

# Configure bundler to not exclude any gem group, so we now get all the gems
# specified in the Gemfile:
RUN bundle config unset --local without

# Install the full gem list:
RUN bundle install
