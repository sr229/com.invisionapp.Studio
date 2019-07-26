![Invison Studio](https://s3.amazonaws.com/www-assets.invisionapp.com/uploads/2018/01/bg-footer.png)

# Invision Studio (Unofficial Flatpak)

Flatpak for Invision Studio

Invision Studio is a new platform inspired by the world’s best design teams. Design, prototype, and animate—all in one place.

# Installing

For now there is no direct way to install the flatpak. Currently you have to build it.

simply get the Winebar SDK and `flatpak-builder`

```bash
# For DNF-based systems
sudo dnf install flatpak flatpak-builder
# For APT-based systems
sudo apt install flatpak flatpak-builder 

# Grab the FlatHub and FlatHub Beta Remotes
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --user --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo

# Build winebar-sdk
export ARCH=x86_64

git clone https://github.com/gasinvein/winebar-sdk/ && cd winebar-sdk && \
flatpak-builder --verbose --install-deps-only --install-deps-from=flathub-beta --arch=$ARCH /dev/null io.winebar.Sdk.yml && \
./build.sh $ARCH ./repo "--verbose" ""

# Add the winebar self-built repo; install the runtimes
flatpak --user remote-add --no-gpg-verify winebar-local ./repo

flatpak install winebar-local io.winebar.Platform//master io.winebar.Sdk//master

# Walk back to the root project and build Flatpak
cd ..
```

Then build the flatpak as is by walking to the project's directory.

```bash
$ flatpak-builder build-dir com.invisionapp.Studio.yml
```
## Copyright

Invision Studio is Copyright &copy; Invision Inc. All Rights Reserved.

The maintainer(s) of this Flatpak is not in any way associated with Invision nor this is a officially-endorsed Invision
Product.