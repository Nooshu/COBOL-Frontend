#define _DEFAULT_SOURCE

#include <errno.h>
#include <stdlib.h>
#include <fcntl.h>
#include <limits.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include <unistd.h>

static void ignore_sigpipe(void) {
    signal(SIGPIPE, SIG_IGN);
}

int GWS_LISTEN(int port) {
    int fd;
    int option;
    struct sockaddr_in address;

    ignore_sigpipe();

    fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) {
        return -1;
    }

    option = 1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &option, sizeof option);

    memset(&address, 0, sizeof address);
    address.sin_family = AF_INET;
    address.sin_port = htons((unsigned short) port);
    address.sin_addr.s_addr = htonl(INADDR_ANY);

    if (bind(fd, (struct sockaddr *) &address, sizeof address) < 0) {
        close(fd);
        return -1;
    }

    if (listen(fd, 16) < 0) {
        close(fd);
        return -1;
    }

    return fd;
}

int GWS_ACCEPT(int listener) {
    int fd;

    do {
        fd = accept(listener, NULL, NULL);
    } while (fd < 0 && errno == EINTR);

    return fd;
}

int GWS_READ(int fd, char *buffer, int length) {
    ssize_t count;

    if (length < 0) {
        return -1;
    }

    do {
        count = read(fd, buffer, (size_t) length);
    } while (count < 0 && errno == EINTR);

    return (int) count;
}

int GWS_WRITE(int fd, const char *buffer, int length) {
    int sent;
    ssize_t count;

    sent = 0;
    while (sent < length) {
        count = write(fd, buffer + sent, (size_t) (length - sent));
        if (count < 0) {
            if (errno == EINTR) {
                continue;
            }
            return -1;
        }
        if (count == 0) {
            return sent;
        }
        sent += (int) count;
    }

    return sent;
}

int GWS_CLOSE(int fd) {
    return close(fd);
}

int GWS_OPEN_FILE(const char *path) {
    return open(path, O_RDONLY);
}

int GWS_RANDOM(unsigned char *buffer, int length) {
    int fd;
    int filled;
    ssize_t count;

    if (length < 0) {
        return -1;
    }

    fd = open("/dev/urandom", O_RDONLY);
    if (fd < 0) {
        return -1;
    }

    filled = 0;
    while (filled < length) {
        count = read(fd, buffer + filled, (size_t) (length - filled));
        if (count < 0) {
            if (errno == EINTR) {
                continue;
            }
            close(fd);
            return -1;
        }
        if (count == 0) {
            close(fd);
            return -1;
        }
        filled += (int) count;
    }

    close(fd);
    return filled;
}

int GWS_FILE_SIZE(const char *path) {
    struct stat info;

    if (stat(path, &info) != 0) {
        return -1;
    }

    if (!S_ISREG(info.st_mode)) {
        return -2;
    }

    if (info.st_size > INT_MAX) {
        return -1;
    }

    return (int) info.st_size;
}

void GWS_FLUSH(void) {
    fflush(stdout);
}

int GWS_REALPATH(const char *path, char *out, int out_len) {
    char resolved[PATH_MAX];
    size_t length;

    if (out_len <= 0 || realpath(path, resolved) == NULL) {
        return -1;
    }

    length = strlen(resolved);
    if ((int) length >= out_len) {
        return -1;
    }

    memcpy(out, resolved, length);
    out[length] = '\0';
    return (int) length;
}
