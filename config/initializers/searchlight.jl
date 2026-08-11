using SearchLight
using SearchLightPostgreSQL
using Genie
using ScafGenie.Config

SearchLight.config.db_config_settings = Config.database_settings()
SearchLight.connect(SearchLight.config.db_config_settings)
