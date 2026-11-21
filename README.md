# Just Say It

Private dictation for macOS. Speak into the app you already use, build a dictionary for your own vocabulary, and transcribe meetings or audio files. Just Say It is based on the open-source macOS app [FluidVoice](https://github.com/altic-dev/FluidVoice) by Altic and its contributors.

## Get the macOS preview

Open the latest successful [Build and Test run](https://github.com/kierantrestain/Justsayit/actions/workflows/build.yml) and download **Just-Say-It-macOS-arm64** under **Artifacts**. Sign in to GitHub to download. Unzip the artifact and then unzip the app archive inside it.

The preview targets Apple Silicon Macs running macOS 15 or later. It is ad-hoc signed for testing. Standard distribution through macOS Gatekeeper requires a Developer ID signature and notarization.

On first launch, select a speech engine and grant microphone access. Accessibility permission lets Just Say It type into other apps. Local models might need to download before your first recording.

## Dictionary

Open **Dictionary → Starter Vocabulary**. Browse or search 245 suggested names, places, and everyday or work terms. Search accepts unaccented input, so `siobhan` finds **Siobhán** and `nguyen` finds **Nguyễn**. Select the entries you say and enable **Parakeet word boosting** to use them with a compatible Parakeet model. You can edit or remove them under **Your Dictionary → … → Custom Words (Advanced)**.

Built-in spellings format distinctive terms such as **GitHub**, **YouTube**, and **Wi-Fi**. Use your own replacement rule to choose a different spelling. Personal names are selectable because spellings vary from person to person.

To bring over a FluidVoice dictionary, export it from FluidVoice and choose **Your Dictionary → … → Import** in Just Say It. Just Say It has its own macOS permissions, preferences, and data folder.

## Build from source

Use Xcode 26 or later. The Xcode project resolves its Swift packages automatically.

```bash
git clone https://github.com/kierantrestain/Justsayit.git
cd Justsayit
open Fluid.xcodeproj
```

Select the **Fluid** scheme. Run `./build.sh` for a signed Debug build with an installed Apple Development identity, or `./build.sh unsigned` for an unsigned build. To package the Apple Silicon preview, run `scripts/package-preview.sh`. It writes the ZIP to `build/preview`.

Run `GITHUB_ACTIONS=true bash Tests/run_ci_checks.sh` to exercise the unsigned CI test sequence on a Mac with full Xcode.

## Privacy and acknowledgments

This build sends no usage analytics. Local speech models run on the Mac after download. If you configure a hosted speech or AI provider, that feature sends data to the provider you select. Transcript issue reports are copied locally for you to review before sharing.

Just Say It retains FluidVoice's GPLv3 license and upstream notices. Its fork-specific changes, first made on 21 November 2026, include the macOS branding and identity, dictionary improvements, and independent feedback and release links. FluidVoice's models and their third-party credits keep their original names.

[GPLv3 license](LICENSE) · [FluidVoice source and credits](https://github.com/altic-dev/FluidVoice) · [Report a Just Say It issue](https://github.com/kierantrestain/Justsayit/issues/new)
