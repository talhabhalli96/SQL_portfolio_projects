--Note: from commands works if you are in project database, if you are in any other database you will need to change database or from command.

--Checking the data

--Deaths table
select *
from covid_data_deaths
order by location

--Vaccinatitions Table
select *
from covid_data_vaccination
order by location

--Deaths Table Exploration
---Looking at data we will be using
select location, date, total_cases, new_cases, total_deaths, new_deaths, population
from covid_data_deaths
order by 1, 2

---Looking at Total cases vs Total deaths (Mortality Rate)
select location, max(cast(total_cases as numeric)) as total_cases,max(cast(total_deaths as numeric)) as total_deaths, (max(cast(total_deaths as numeric))/max(cast(total_cases as numeric)))*100 as Mortality_Rate
from covid_data_deaths
where continent is not null
group by location
order by location

---Creating view of Mortality Rate
create view Mortality_rate
as
select location, max(cast(total_cases as numeric)) as total_cases,max(cast(total_deaths as numeric)) as total_deaths, (max(cast(total_deaths as numeric))/max(cast(total_cases as numeric)))*100 as Mortality_Rate
from covid_data_deaths
where continent is not null
group by location


---Total cases vs Total Population
select location, max(cast(total_cases as numeric)) as total_cases,max(cast(population as numeric)) as population, (max(cast(total_cases as numeric))/max(cast(population as numeric)))*100 as Infection_Rate
from covid_data_deaths
where continent is not null
group by location
order by location

---Creating view of Percentage of People Affected
create view Infection_Rate
as
select location, max(cast(total_cases as numeric)) as total_cases,max(cast(population as numeric)) as population, (max(cast(total_cases as numeric))/max(cast(population as numeric)))*100 as Infection_Rate
from covid_data_deaths
where continent is not null
group by location

---Total Deaths vs Total Population
select location, max(cast(total_deaths as numeric)) as total_deaths,max(cast(population as numeric)) as population, (max(cast(total_deaths as numeric))/max(cast(population as numeric)))*100000 as Deaths_per_100000
from covid_data_deaths
where continent is not null
group by location
order by location

---Creating view of deaths per 100000 people
create view Deaths_per_100000
as
select location, max(cast(total_deaths as numeric)) as total_deaths,max(cast(population as numeric)) as population, (max(cast(total_deaths as numeric))/max(cast(population as numeric)))*100000 as Deaths_per_100000
from covid_data_deaths
where continent is not null
group by location

---Calculations with respect to continent(deaths)
select location, max(cast(total_cases as numeric)) as total_cases,max(cast(population as numeric)) as population, 
 max(cast(total_deaths as numeric)) as total_deaths,(max(cast(total_cases as numeric))/max(cast(population as numeric)))*100 as Infection_Rate,
 (max(cast(total_deaths as numeric))/max(cast(total_cases as numeric)))*100 as Mortality_Rate, (max(cast(total_deaths as numeric))/max(cast(population as numeric)))*100000 as Deaths_per_100000
from covid_data_deaths
where continent is null
group by location
order by location

---Creating view of Continental Data Calculations
create view continental_death
as
select location, max(cast(total_cases as numeric)) as total_cases,max(cast(population as numeric)) as population, 
 max(cast(total_deaths as numeric)) as total_deaths,(max(cast(total_cases as numeric))/max(cast(population as numeric)))*100 as Infection_Rate,
 (max(cast(total_deaths as numeric))/max(cast(total_cases as numeric)))*100 as Mortality_Rate, (max(cast(total_deaths as numeric))/max(cast(population as numeric)))*100000 as Deaths_per_100000
from covid_data_deaths
where continent is null
group by location

--Now we take a look at Total vaccination vs Population
select death.location, max(death.population)as population, max(cast(vac.total_vaccinations as numeric)) as total_vaccinations, (max(cast(vac.total_vaccinations as numeric))/max(death.population))*100 as vaccines_per_100_people
from covid_data_deaths as death
join covid_data_vaccination as vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null
group by death.location
order by death.location

---Creating view of vaccinations administred
create view vaccines_per_100_people
as
select death.location, max(death.population)as population, max(cast(vac.total_vaccinations as numeric)) as total_vaccinations, (max(cast(vac.total_vaccinations as numeric))/max(death.population))*100 as vaccines_per_100_people
from covid_data_deaths as death
join covid_data_vaccination as vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null
group by death.location


-- Timeline of Vaccination Process
--Using temp table
DROP Table if exists #Timeline_vaccinations
Create Table #Timeline_vaccinations
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
people_vaccinated numeric
)

Insert into #Timeline_vaccinations
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by death.Location Order by death.location, death.Date) as People_Vaccinated

From covid_data_deaths death
Join covid_data_vaccination vac
	On death.location = vac.location
	and death.date = vac.date

Select *, (people_vaccinated/Population)*100 as population_percentage_vaccinated
from #Timeline_vaccinations

--continent vaccine data
create view vaccines_continent_income_bracket
as
select death.location, max(death.population)as population, max(cast(vac.total_vaccinations as numeric)) as total_vaccinations, (max(cast(vac.total_vaccinations as numeric))/max(death.population))*100 as vaccines_per_100_people
from covid_data_deaths as death
join covid_data_vaccination as vac
on death.location = vac.location and death.date = vac.date
where death.continent is null
group by death.location