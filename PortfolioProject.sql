--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths
--ORDER BY 1, 2

-- Total Cases vs Total Deaths

SELECT *
FROM PortfolioProject..CovidDeaths

SELECT continent, location, date, total_cases, new_cases, total_deaths, new_deaths, population
FROM PortfolioProject..CovidDeaths

-- Total Cases vs Total Deaths
--Shows the likelihood of dying if you get Covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Shows what percentage of the population per location got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC

-- Showing countries with highest death count per population

SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent = 'North America'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Side Note on changing data types on the data temporarily using Casting
-- If the data type isn't correct for the calculation you are attempting, you need to cast the data as an int or whatever data type needed
-- SELECT Location, MAX(cast(total_deaths as int)) 
-- SELECT Location, MAX(CONVERT(int, total_deaths))

-- accurate data but loses the drill down affect
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL -- AND location NOT LIKE '%income%' AND location <> 'World'
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing the continents with the highest death count
-- data counts aren't including all of the countries in each continent

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT date, SUM(new_cases) AS Cases, SUM(new_deaths) AS Deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND new_cases > 0 AND new_cases > new_deaths
GROUP BY date
ORDER BY 1

SELECT SUM(new_cases) AS Cases, SUM(new_deaths) AS Deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND new_cases > 0 AND new_cases > new_deaths
--GROUP BY date
ORDER BY 1

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea	
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea	
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea	
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea	
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
