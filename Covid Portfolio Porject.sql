SELECT *
FROM [PortfolioProject ]..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM [PortfolioProject ]..CovidVac
--order by 3,4

--Select data that we are going to be using


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject ]..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [PortfolioProject ]..CovidDeaths
WHERE location like '%states%'
and continent is not null
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM [PortfolioProject ]..CovidDeaths
WHERE location like '%states%'
order by 1,2


-- Looking at Country with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PersonPopulationInfected
FROM [PortfolioProject ]..CovidDeaths
--WHERE location like '%states%'
Group by location, population
order by PersonPopulationInfected desc



-- Showing countries with highest death count per population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [PortfolioProject ]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
Group by location
order by TotalDeathCount desc


-- LETS' BREAK THINGS DOWN BY CONTINENT


-- Showing the continent with the highest deathcount

SELECT Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [PortfolioProject ]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage--, (total_deaths/total_cases)*100 as DeathPercentage
FROM [PortfolioProject ]..CovidDeaths 
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
order by 1,2


-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVac vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinatedd)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVac vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinatedd/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinated numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVac vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VIRSUALIZATION

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVac vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


SELECT *
FROM PercentPopulationVaccinated