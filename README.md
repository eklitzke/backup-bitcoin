## Instructions

This is a simple backup script
for [Bitcoin Core](https://bitcoin.org/en/download). It creates a backup of your
`wallet.dat` file, GPG encrypts it, and then copies it to
a [Google Cloud Storage](https://cloud.google.com/storage/) bucket.

The script can operate both if Bitcoin Core is shut down, or if Bitcoin Core is
running and accepting RPC commands. See the RPC usage note below for details.

Run the script like this:

```bash
# GPG encrypt wallet.dat and copy it to the cloud.
$ ./backup-bitcoin.sh -b gs://target-bucket/ -u gpg-recipient
```

You should set the GPG recipient to be yourself, since you want to be the only
person who can decrypt the file.

### A Note On RPC Mode

The script checks if Bitcoin Core is running by looking for a `.cookie` file in
the Bitcoin data directory. If you are running `bitcoin-qt`, but don't have
`server=1` set in your `bitcoin.conf`, the `.cookie` file will not exist, and
that will cause this script to directly copy the `wallet.dat` file without using
the RPC interface. The vast majority of the time this is OK, but there's
technically a rare race condition where the wallet file could be copied in a
corrupted state. This would happen if the backup script is run exactly as a new
transaction comes in on the wallet. Therefore if you are using `bitcoin-qt`, you
are responsible for ensuring that you set `server=1` appropriately.

These are the recommended `bitcoin.conf` settings for using the RPC interface:

```ini
rpcbind=127.0.0.1
server=1
```
