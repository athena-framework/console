# README

Template repo for creating a new Athena component. Scaffolds the Crystal shard's structure as well as define CI etc.

**NOTE:** This repo assumes the component will be in the `athena-framework` org.  If it is to be used outside of the org, be sure to update URLs accordingly.

1. Find/replace `COMPONENT_NAME` with the name of the component.  This is used as the shard's name.  E.x. `logger`.
  1.1 Be sure to rename the file in `./src`, and `./spec` as well.

1. Replace `NAMESPACE_NAME` with the name of the component's namespace.  Documentation for this component will be grouped under this. E.x. `Logger`.

1. Find/replace `CREATOR_NAME` with your Github display name. E.x. `George Dietrich`.

1. Find/replace `CREATOR_USERNAME` with your Github username. E.x. `blacksmoke16`.

1. Find/replace `CREATOR_EMAIL` with your desired email

   5.1 Can remove this if you don't wish to expose an email.

1. Find/replace `ALIAS_NAME` with the three letter alias for this component; A + 2 letter shortcut to `NAMESPACE_NAME`.  E.x. `ALG`.

1. Find/replace `DESCRIPTION` with a short description of what the component does.

1. Define a repo secret `ACCESS_TOKEN` for CI deploys to work.

   8.1 Alter [CI](./.github/workflows/ci.yml) and [Deployment](./.github/workflows/deployment.yml) scrips as needed.  Such as adding custom `crystal docs` command or adding an `Install Dependencies` step.

Delete from here up
# NAMESPACE_NAME

[![CI](https://github.com/athena-framework/COMPONENT_NAME/workflows/CI/badge.svg)](https://github.com/athena-framework/COMPONENT_NAME/actions?query=workflow%3ACI)
[![Latest release](https://img.shields.io/github/release/athena-framework/COMPONENT_NAME.svg)](https://github.com/athena-framework/COMPONENT_NAME/releases)

DESCRIPTION

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  athena-COMPONENT_NAME:
    github: athena-framework/COMPONENT_NAME
```

2. Run `shards install`

## Documentation

Everything is documented in the [API Docs](https://athena-framework.github.io/COMPONENT_NAME/Athena/NAMESPACE_NAME.html).

## Contributing

1. Fork it (https://github.com/athena-framework/COMPONENT_NAME/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [CREATOR_NAME](https://github.com/CREATOR_USERNAME) - creator and maintainer
