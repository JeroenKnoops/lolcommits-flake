# lolcommits-flake

A Nix flake for [lolcommits](https://lolcommits.github.io/) - capture git commit pictures on macOS.

## Features

- Captures a webcam snapshot every time you make a git commit
- Adds the commit message as overlay text on the image
- Works with Nix flakes and home-manager on macOS

## Usage

### With flakes (recommended)

#### 1. Add to your flake inputs

```nix
{
  inputs = {
    # ...
    lolcommits-flake.url = "github:jeroenknoops/lolcommits-flake";
    # or for a specific version/branch:
    # lolcommits-flake.url = "github:jeroenknoops/lolcommits-flake/v0.18.0";
  };
}
```

#### 2. Pass to home-manager

In your `flake.nix`:

```nix
outputs = { nixpkgs, home-manager, lolcommits-flake, ... }@inputs: {

  homeConfigurations."your-host" = home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs { system = "aarch64-darwin"; };
    
    modules = [
      ./home.nix
    ];

    extraSpecialArgs = {
      lolcommits = lolcommits-flake.packages."aarch64-darwin".default;
    };
  };
};
```

#### 3. Add to home.nix

```nix
{ config, pkgs, lolcommits, ... }:

{
  home.packages = [
    lolcommits
  ];
}
```

### With home-manager (standalone)

If you prefer not to use a separate flake, you can inline the package definition:

```nix
# In your flake.nix inputs
lolcommits-flake.url = "github:jeroenknoops/lolcommits-flake";

# Or use the FlakeHub version:
# lolcommits-flake.url = "https://flakehub.com/f/jeroenknoops/lolcommits-flake/0.1.0.tar.gz";
```

### Development shell

For development, you can use the included dev shell:

```bash
nix develop
```

This provides:
- Ruby 3.3
- Bundler and bundix
- ImageMagick (for image processing)
- FFmpeg (for video capture)

## Setup

After installing lolcommits, you'll need to configure it for each git repository:

```bash
cd your-git-repo
lolcommits install
```

This creates a git hook that captures a photo on each commit.

### First-time camera permission (macOS)

On macOS, you'll need to grant camera permission to your terminal app:

1. Open **System Preferences** > **Privacy & Security** > **Camera**
2. Find your terminal app (e.g., Terminal, iTerm2, Warp) and enable it

### Configuration

Configure lolcommits with:

```bash
lolcommits configure
```

Options include:
- Camera selection (if you have multiple cameras)
- Camera delay (countdown before capture)
- Overlay text style
- Output directory for commits

## Troubleshooting

### Camera not working

1. Ensure camera permission is granted in System Preferences
2. Check that no other application is using the camera
3. Try specifying the camera explicitly: `lolcommits configure --camera /dev/video0`

### Gem not found errors

Make sure `GEM_HOME` and `GEM_PATH` are set correctly:

```bash
export GEM_HOME="$HOME/.gems"
export GEM_PATH="$GEM_HOME/ruby/3.3.0"
export PATH="$GEM_HOME/bin:$GEM_HOME/ruby/*/bin:$PATH"
```

### Build errors

This flake requires:
- macOS (aarch64-darwin)
- ImageMagick
- FFmpeg

If you encounter build issues, ensure all dependencies are available.

## Contributing

Contributions are welcome! Please open an issue or pull request on GitHub.

## License

MIT License - see [lolcommits](https://github.com/lolcommits/lolcommits) for details.
