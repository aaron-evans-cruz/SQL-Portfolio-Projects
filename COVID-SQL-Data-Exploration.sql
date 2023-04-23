/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4


SELECT location, 
	   date, 
	   total_cases, 
	   new_cases, 
	   total_deaths, 
	   population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths

Select location, 
	   date, 
	   total_cases, 
	   total_deaths, 
	   (CAST(total_deaths AS decimal)/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WhERE location LIKE '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location,
	   date, 
	   population,
	   total_cases, 
	   (CAST(total_cases AS decimal)/population)*100 AS PercentagePopulationEffected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, 
	   population, 
	   MAX(total_cases) AS HighestInfectionCount, 
	   (MAX(total_cases) / population)*100 AS PercentagePopulationEffected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationEffected DESC


-- Showing Countries with Highest Death Rate

SELECT location, 
	   MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing Continent (and various group) Death Rates

SELECT location, 
       MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT SUM(new_cases) AS total_cases, 
       SUM(CAST(new_deaths AS int)) AS total_deaths, 
	   SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1, 2


-- Getting a rolling tally by country of number of people vaccinated, and a rolling tally
-- of the percentage of the population that is vaccinated.
-- Using a CTE.

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(CONVERT(bigint, vac.new_vaccinations)) 
			OVER (PARTITION BY dea.location 
			ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- Order By 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PctPeopleVaccinated
FROM PopvsVac


-- Getting a rolling tally by country of number of people vaccinated, and a rolling tally
-- of the percentage of the population that is vaccinated.
-- Using a Temp Table.

CREATE TABLE #PercentPeopleVaccinated
(
	Continent nvarchar(255), 
	Location nvarchar(255), 
	Date datetime, 
	Population numeric, 
	New_Vaccinations numeric, 
	RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(CONVERT(bigint, vac.new_vaccinations)) 
			OVER (PARTITION BY dea.location 
			ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- Order By 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PctPeopleVaccinated
FROM #PercentPeopleVaccinated


-- Creating some Views to use later in visualizations. Commenting out Order By as can't use when setting up a view.
-- Including it instead in the Select statement that displays everything from the newly created view.

CREATE VIEW PercentPeopleVaccinated AS
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(CONVERT(bigint, vac.new_vaccinations)) 
			OVER (PARTITION BY dea.location 
			ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- Order By 2, 3

SELECT *
FROM PercentPeopleVaccinated
Order By 2, 3


CREATE VIEW CountryDeaths AS
SELECT location, 
	   MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
-- ORDER BY TotalDeathCount DESC

SELECT *
FROM CountryDeaths
ORDER BY TotalDeathCount DESC


CREATE VIEW ContinentDeaths as
SELECT location, 
       MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
-- ORDER BY TotalDeathCount DESC

SELECT * 
FROM ContinentDeaths
ORDER BY TotalDeathCount DESC