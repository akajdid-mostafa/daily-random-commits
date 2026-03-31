# GitHub Daily Random Commit Bot (macOS)

This project helps you create and push a random number of commits (default: 10-20) once per day.

## 1) Requirements

- macOS (uses `launchd`)
- Git installed and authenticated with GitHub (`git push` works manually)
- A local git repo already connected to `origin`

## 2) Files

- `daily_commit.sh`: creates random commits and pushes
- `setup_launchd.sh`: installs a daily scheduler job

## 3) Make scripts executable

```bash
cd /Users/ocean_dev2/stage/github-daily-commit-bot
chmod +x daily_commit.sh setup_launchd.sh
```

## 4) Test once manually

```bash
./daily_commit.sh /absolute/path/to/your/repo 10 20
```

Example:

```bash
./daily_commit.sh /Users/ocean_dev2/stage/front-end-Monpatient 10 20
```

## 5) Schedule daily run

Install a launch agent that runs every day at 21:30:

```bash
./setup_launchd.sh /absolute/path/to/your/repo 21 30
```

Example:

```bash
./setup_launchd.sh /Users/ocean_dev2/stage/front-end-Monpatient 21 30
```

## 6) Useful commands

Check scheduler loaded:

```bash
launchctl list | rg com.oceandev.dailygit
```

Run now (without waiting for schedule):

```bash
/bin/bash /Users/ocean_dev2/stage/github-daily-commit-bot/daily_commit.sh /absolute/path/to/your/repo 10 20
```

Remove scheduler:

```bash
launchctl unload ~/Library/LaunchAgents/com.oceandev.dailygit.plist
rm ~/Library/LaunchAgents/com.oceandev.dailygit.plist
```

## Notes

- Commits are written to `.daily-activity.log` in your repo.
- By default, script pushes to your current checked-out branch.
- You can set branch manually:

```bash
BRANCH_NAME=main ./daily_commit.sh /absolute/path/to/your/repo 10 20
```
