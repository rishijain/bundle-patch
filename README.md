# 🔒 bundle-patch

A command-line tool to **automatically patch vulnerable gems** in your Gemfile using [`bundler-audit`](https://github.com/rubysec/bundler-audit) under the hood.

It parses audit output, finds the **best patchable version** for each vulnerable gem, and updates your Gemfile accordingly.

---

## ✨ Features

- Runs `bundle audit` and parses vulnerabilities
- Computes the minimal patchable version required
- Updates your `Gemfile` (and optionally runs `bundle install`)
- Supports patch/minor/major upgrade strategies
- Handles indirect dependencies by explicitly adding them
- Has a dry-run mode

---

## 💡 Example

```bash
bundle-patch --mode=minor
```

Example output

```
🔍 Running `bundle-audit check --format json`...
🔒 Found 2 vulnerabilities:
- sidekiq (5.2.10): sidekiq Denial of Service vulnerability
  ✅ Patchable → 6.5.10
- actionpack (6.1.4.1): XSS vulnerability
  ✅ Patchable → 6.1.7.7
📝 Backing up Gemfile to Gemfile.bak...
🔧 Updating existing gem: actionpack to '6.1.7.7'
➕ Gem sidekiq is a dependency. Adding it explicitly to Gemfile with version 6.5.10.
✅ Gemfile updated!
📦 Running `bundle install`...
✅ bundle install completed successfully
```

## ⚙️ Options

| Option         | Description                                                               |
| -------------- | ------------------------------------------------------------------------- |
| `--mode=patch` | Only allow patch-level updates (default)                                  |
| `--mode=minor` | Allow minor version updates                                               |
| `--mode=all`   | Allow all updates including major versions                                |
| `--dry-run`    | Only print what would be changed, don’t touch the Gemfile or install gems |
| `--no-install` | Modify the Gemfile, but skip `bundle install`                             |

## 📦 Installation

Add this gem to your system:

```bash
gem install bundle-patch
```

Or add it to your project's Gemfile for use in development:

```bash
# Gemfile
group :development do
  gem 'bundle-patch'
end
```

And then:

```
bundle install
```

## 🧼 How it works

1. Runs `bundle audit check --format json`
2. Groups advisories by gem
3. Determines the best patchable version for each gem based on `--mode`
4. Ensures the gem is either updated or explicitly added to the `Gemfile`
5. Optionally runs `bundle install` (unless `--no-install` or `--dry-run` is used)
