![Invison Studio](https://s3.amazonaws.com/www-assets.invisionapp.com/uploads/2018/01/bg-footer.png)

# Invision Studio (Unofficial Flatpak)

Flatpak for Invision Studio

Invision Studio is a new platform inspired by the world’s best design teams. Design, prototype, and animate—all in one place.

# Installing

For now there is no direct way to install the flatpak. Currently you have to build it.

simply get the freedesktop SDK (18.08) and `flatpak-builder`

```bash
# For DNF-based systems
sudo dnf install flatpak flatpak-builder
# For APT-based systems
sudo apt install flatpak flatpak-builder 

# Get the Freedesktop 18.08 SDK runtime
flatpak install flathub io.winebar.Platform//19.08beta io.winebar.Sdk//19.08beta
```

Then build the flatpak as is by walking to the project's directory.

```bash
$ flatpak-builder build-dir com.invisionapp.Studio.yml
```
## Copyright

Invision Studio is Copyright &copy; Invision Inc. All Rights Reserved.

The maintainer(s) of this Flatpak is not in any way associated with Invision nor this is a officially-endorsed Invision
Product.