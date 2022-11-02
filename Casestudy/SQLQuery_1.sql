SELECT *
FROM CovidData..CovidDeaths
WHERE continent is not null
order by 3,4

-- Explore data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidData..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Total Cases vs Tota Deaths
-- Shows how likely you will die from Covid in each country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidData..CovidDeaths
WHERE location = 'Australia' and continent is not null
ORDER BY 1, 2

-- Total Cases vs Population
-- Percentage of population have covid 
SELECT location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
FROM CovidData..CovidDeaths
WHERE location = 'Australia' and continent is not null
ORDER BY 1, 2

-- What country has the highest infection rate?
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercentage
FROM CovidData..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY CovidPercentage DESC

-- Showing the location with the highest death count
SELECT location, max(total_deaths) as HighestDeathCount
FROM CovidData..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Showing the continent with the highest death count
SELECT location, max(total_deaths) as HighestDeathCount
FROM CovidData..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Golbal numbers
-- Total Death percentage per date
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/sum(new_cases) * 100 as DeathPercentage
FROM CovidData..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- Looking at Total Population vs Vaccinations Per Day
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) 
as PeopleVaccinated
FROM CovidData..CovidDeaths death
JOIN CovidData..TotalVaccinations vac 
    ON death.location=vac.location and death.date = vac.date
WHERE death.continent is not null
ORDER BY 2,3

-- Percentage people vac using CTE
WITH PopulationVSVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
AS (
    SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) 
as PeopleVaccinated
FROM CovidData..CovidDeaths death
JOIN CovidData..TotalVaccinations vac 
    ON death.location=vac.location and death.date = vac.date
WHERE death.continent is not null
)

SELECT *, (PeopleVaccinated/population) * 100
from PopulationVSVac


-- Create view to store data

Create VIEW PercentagePopulationVaccinated as 
    WITH PopulationVSVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
AS (
    SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) 
as PeopleVaccinated
FROM CovidData..CovidDeaths death
JOIN CovidData..TotalVaccinations vac 
    ON death.location=vac.location and death.date = vac.date
WHERE death.continent is not null
)

SELECT *, (PeopleVaccinated/population) * 100 as PeopleVaccinatedPercentage
from PopulationVSVac



