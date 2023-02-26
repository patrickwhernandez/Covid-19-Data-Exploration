-- Covid 19 Data Exploration

Select *
From CovidProject..CovidDeaths
Where continent is not null
Order by 3,4

-- Select data

Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Compare total cases to total deaths
-- Shows what the odds of you dying if you contracted Covid in your country
-- Locations: Japan, South Korea, United States

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location = 'Japan'
and continent is not null 
Order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location = 'South Korea'
and continent is not null 
Order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location = 'United States'
and continent is not null 
Order by 1,2

-- Compare total cases to population
-- Shows what percentage of the population in your country have contracted Covid
-- Locations: Japan, South Korea, United States

Select location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
From CovidProject..CovidDeaths
Where location = 'Japan'
order by 1,2

Select location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
From CovidProject..CovidDeaths
Where location = 'South Korea'
order by 1,2

Select location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
From CovidProject..CovidDeaths
Where location = 'United States'
order by 1,2

-- Countries with the highest total cases to population ratio

Select location, population, MAX(total_cases) as TotalInfectedCount, MAX(total_cases/population)*100 as PopulationInfectedPercentage
From CovidProject..CovidDeaths
Group by Location, Population
Order by PopulationInfectedPercentage Desc

-- Countries with the highest total deaths from Covid

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null 
Group by location
Order by TotalDeathCount Desc

-- Continents with the highest total deaths from Covid

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where location not like '%income%'
and continent is null 
Group by location
Order by TotalDeathCount Desc

-- Compare total cases to total deaths worldwide

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
where continent is not null

-- Compare date to running total of number of vaccinated people
-- Location: Japan, South Korea, United States

Select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RunningTotalPeopleVaccinated
From CovidProject..CovidDeaths as dea
JOIN CovidProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.location = 'Japan'
and dea.continent is not null
Order by 1,2

Select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RunningTotalPeopleVaccinated
From CovidProject..CovidDeaths as dea
JOIN CovidProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.location = 'South Korea'
and dea.continent is not null
Order by 1,2

Select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RunningTotalPeopleVaccinated
From CovidProject..CovidDeaths as dea
JOIN CovidProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.location = 'United States'
and dea.continent is not null
Order by 1,2

-- Compare date to running total of number of Covid cases

Select location, date, population, new_cases, SUM(new_cases) OVER (Partition by location Order by location, date) as RunningTotalCases
From CovidProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Create temp table of running total of number of Covid cases

Drop Table if exists #CovidPopulationPercentage
Create Table #CovidPopulationPercentage
(
location nvarchar(255),
date datetime,
population numeric,
new_cases numeric,
RunningTotalCases numeric
)

Insert into #CovidPopulationPercentage
Select location, date, population, new_cases, SUM(new_cases) OVER (Partition by location Order by location, date) as RunningTotalCases
From CovidProject..CovidDeaths

-- Compare running total of number of Covid cases to population
-- Locations: Japan, South Korea, United States

Select *, (RunningTotalCases / population) * 100 as CovidPopulationPercentage
From #CovidPopulationPercentage
Where location = 'Japan'
Order by 1,2

Select *, (RunningTotalCases / population) * 100 as CovidPopulationPercentage
From #CovidPopulationPercentage
Where location = 'South Korea'
Order by 1,2

Select *, (RunningTotalCases / population) * 100 as CovidPopulationPercentage
From #CovidPopulationPercentage
Where location = 'United States'
Order by 1,2