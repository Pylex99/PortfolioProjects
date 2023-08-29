/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT COUNT (*) FROM coviddeaths;

SELECT * FROM coviddeaths
ORDER BY 3, 4;
SELECT * FROM covidvaccinations
ORDER BY 3, 4;

-- Selecting Data needed to start

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1, 2;

-- Total Cases vs. Total Deaths
-- Shows the likelihood of fatality for a person if infected with Covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Total Cases vs Population
-- Percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
FROM coviddeaths
WHERE location = 'united states'
ORDER BY 1, 2;


-- Countries with highest infection rate compared to population

SELECT location, population, MAX(CAST(total_cases AS UNSIGNED)) AS HighestInfectionCount, MAX(total_cases/population)*100 as InfectionPercentage
FROM coviddeaths
GROUP BY location, population
ORDER BY InfectionPercentage DESC;


-- Countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
LIMIT 9, 18446744073709551615;


-- Break down by Continents
-- Showing CONTINETS with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
LIMIT 9;


-- Global overall death count

SELECT  SUM(CAST(new_cases AS UNSIGNED)) AS TotalCases, SUM(CAST(new_deaths AS UNSIGNED)) AS TotalDeaths, SUM(CAST(new_deaths AS UNSIGNED))/SUM(CAST(new_cases AS UNSIGNED))*100 as DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Global Death count per day

SELECT date, SUM(CAST(new_cases AS UNSIGNED)) AS TotalCases, SUM(CAST(new_deaths AS UNSIGNED)) AS TotalDeaths, SUM(CAST(new_deaths AS UNSIGNED))/SUM(CAST(new_cases AS UNSIGNED))*100 as DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


-- Total Population vs Total Vaccination by Date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY  2, 3;


-- Total Population vs Total Vaccination by Country

SELECT  dea.location, MAX(dea.population), SUM(vac.new_vaccinations)
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY location
ORDER BY  1;


-- Total Population vs Total Vaccination by Continent

SELECT  dea.continent, MAX(dea.population), SUM(vac.new_vaccinations)
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY continent
ORDER BY  1;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine(Days with 0 new vaccinations ignored) Rolling Count of people vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.location NOT IN (
	'South America', 'Asia', 'Oceania', 'North America', 'Europe', 'Africa', 'European Union', 'High Income', 'Low Income', 'Lower middle income', 'Upper middle income', 'World'
    ) AND
    vac.new_vaccinations > 0
ORDER BY  2, 3;


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.location NOT IN (
	'South America', 'Asia', 'Oceania', 'North America', 'Europe', 'Africa', 'European Union', 'High Income', 'Low Income', 'Lower middle income', 'Upper middle income', 'World'
    ) AND
    vac.new_vaccinations > 0
ORDER BY  2, 3 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinatedPerPopulation
FROM PopvsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query  

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
	Continent VARCHAR(255),
	Location VARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
);
INSERT INTO PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM coviddeaths AS dea
	JOIN covidvaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
	WHERE dea.location NOT IN (
		'South America', 'Asia', 'Oceania', 'North America', 'Europe', 'Africa', 'European Union', 'High Income', 'Low Income', 'Lower middle income', 'Upper middle income', 'World'
		) AND
		vac.new_vaccinations > 0
	ORDER BY  2, 3;
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated;

-- Creating View to store data for later Visualization

CREATE VIEW PercentPopulationVaccinated AS
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM coviddeaths AS dea
	JOIN covidvaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
	WHERE dea.location NOT IN (
		'South America', 'Asia', 'Oceania', 'North America', 'Europe', 'Africa', 'European Union', 'High Income', 'Low Income', 'Lower middle income', 'Upper middle income', 'World'
		) AND
		vac.new_vaccinations > 0
	ORDER BY  2, 3;
