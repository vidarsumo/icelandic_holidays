
library(sumots)
library(AzureStor)
library(AzureKeyVault)



azure_connections <- sumo_connect_azure(type = "prod")

isl_holidays <- sumo_get_holidays("iceland", 2010:2040)


isl_holidays %>%
    storage_write_csv(azure_connections$container_prod_clean, "iceland_covid_holiday/iceland_public_holidays.csv")

