# Application Architecture

## Overview

The application consists of three core components: a web server, message queue, and database. They work together to handle client requests, process asynchronous work, and store persistent state.

## Components

### Web Server

Routes incoming client requests to backend services. Handles request validation, authentication, logging, and response compression.

### Message Queue

Enables asynchronous processing. Services publish events to the queue; consumers process them asynchronously. Supports multiple message types and priorities.

### Database

Stores application state using PostgreSQL. Chosen for strong ACID guarantees, complex query support, and scalability.
