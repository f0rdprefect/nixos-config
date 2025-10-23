{
  pkgs,
  config,
  lib,
  host,
  ...
}:

{
  services.homebox = {
    enable = true;
    settings = {
      HBOX_STORAGE_DATA = "/srv/MQ03UBB300/tank/homebox";
      HBOX_DATABASE_DRIVER = "sqlite3";
      HBOX_DATABASE_SQLITE_PATH = "/srv/MQ03UBB300/tank/homebox/homebox.db?_pragma=busy_timeout=999&_pragma=journal_mode=WAL&_fk=1";
      HBOX_OPTIONS_ALLOW_REGISTRATION = "true";
      HBOX_OPTIONS_CHECK_GITHUB_RELEASE = "false";
      HBOX_MODE = "production";
      HBOX_OPTIONS_CURRENCY_CONFIG = "/srv/MQ03UBB300/tank/homebox/currencies.json";

    };
  };
}
