## Instructions

This is a simple backup script
for [Bitcoin Core](https://bitcoin.org/en/download). It creates a backup of your
`wallet.dat` file, GPG encrypts it, and then copies it to
a [Google Cloud Storage](https://cloud.google.com/storage/) bucket.

Ensure that you have Bitcoin set up to allow RPC commands, e.g. by adding the
following to your `bitcoin.conf`:

```ini
rpcbind=127.0.0.1
server=1
```

Then run the script like this:

```
$ ./backup-bash.sh -b gs://target-bucket/ -u gpg-recipient
```

Typically you would set the GPG recipient to be yourself, since you want to be
the only person who can decrypt the file.
