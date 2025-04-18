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
- Creates backup of your Gemfile before changes

---

## 📋 Requirements

- Ruby 2.6 or later
- Bundler installed
- bundler-audit installed (will be installed automatically if missing)

---

## 📦 Installation

Add this gem to your system:

```bash
gem install bundle-patch
```

Or add it to your project's Gemfile for use in development:

```ruby
# Gemfile
group :development do
  gem 'bundle-patch'
end
```

And then:

```bash
bundle install
```

---

## 💡 Examples

### Basic Usage
```bash
bundle-patch
```
This will run in patch mode (default) and update only patch versions.

### Minor Version Updates
```bash
bundle-patch --mode=minor
```
Example output:
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

### Dry Run Mode
```bash
bundle-patch --dry-run
```
This will show what would be changed without making any actual changes.

### Skip Bundle Install
```bash
bundle-patch --skip-bundle-install
```
This will update the Gemfile but skip running `bundle install`.

### Major Version Updates
```bash
bundle-patch --mode=all
```
This will allow updates to any version that fixes the vulnerability.

---

## ⚙️ Options

| Option                  | Description                                                               | Default |
| ----------------------- | ------------------------------------------------------------------------- | ------- |
| `--mode=patch`          | Only allow patch-level updates (e.g., 1.0.0 → 1.0.1)                     | ✓       |
| `--mode=minor`          | Allow minor version updates (e.g., 1.0.0 → 1.1.0)                        |         |
| `--mode=all`            | Allow all updates including major versions (e.g., 1.0.0 → 2.0.0)         |         |
| `--dry-run`             | Only print what would be changed, don't touch the Gemfile or install gems | false   |
| `--skip-bundle-install` | Modify the Gemfile, but skip `bundle install`                             | false   |

---

## 🧼 How it works

1. Runs `bundle audit check --format json`
2. Groups advisories by gem
3. Determines the best patchable version for each gem based on `--mode`
4. Creates a backup of your Gemfile (Gemfile.bak)
5. Ensures the gem is either updated or explicitly added to the `Gemfile`
6. Optionally runs `bundle install` (unless `--skip-bundle-install` or `--dry-run` is used)

---

## 🔍 Troubleshooting

### Bundle Install Fails
If `bundle install` fails after updating:
1. Check the error message
2. You can revert to the backup: `cp Gemfile.bak Gemfile`
3. Try running `bundle install` manually to see more detailed errors

### Gem Can't Be Patched
If a gem can't be patched in your chosen mode:
1. Try running with `--mode=all` to see all possible updates
2. Check if there are any version conflicts in your Gemfile
3. Consider manually updating the gem to a specific version

### Security Considerations
- Always review the changes made to your Gemfile
- Test your application after applying updates
- Consider running your test suite after updates
- Check the changelog of updated gems for breaking changes

---

## 🤝 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/bundle-patch.

---

## 📄 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
