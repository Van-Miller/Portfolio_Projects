SELECT *
FROM CovidPortfolio..CovidDeaths
ORDER BY 3,4


--SELECT *
--FROM CovidPortfolio..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolio..CovidDeaths
ORDER BY 1,2

--Columns were imported as nvarchar; need to switch data type to perform calculations
--We could use cast function to not permanently change but for our uses this is fine
ALTER TABLE dbo.CovidDeaths ALTER COLUMN total_cases float
ALTER TABLE dbo.CovidDeaths ALTER COLUMN total_deaths float

-- Looking at Total Cases vs Total Deaths in US
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidPortfolio..CovidDeaths
WHERE LOCATION LIKE '%states%'
ORDER BY 1,2

--Looking at Total Cases vs Population in US
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PositiveCasePercentage
FROM CovidPortfolio..CovidDeaths
WHERE LOCATION LIKE '%states%'
ORDER BY 1,2

--Looking at Countries with Highest Rate of Infection compared to Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PositiveCasePercentage
FROM CovidPortfolio..CovidDeaths
GROUP BY Location, population
ORDER BY PositiveCasePercentage desc

--Showing Countries with Highest Death Count per Population
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM CovidPortfolio..CovidDeaths
GROUP BY location
ORDER BY TotalDeathCount desc

--Since previous query returned groupings like 'World', 'Europe', 'High Income'
--we eliminate these irrelevant results
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM CovidPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population
--Must eliminate income groupings from results
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidPortfolio..CovidDeaths
WHERE location NOT IN ('High income', 'Upper middle income', 'Lower middle income', 'Low income', 'World', 'European Union') AND 
	continent is null
GROUP BY location
ORDER BY TotalDeathCount desc



--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidPortfolio..CovidDeaths dea
JOIN CovidPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
FROM CovidPortfolio..CovidDeaths dea
JOIN CovidPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
With PopsvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
FROM CovidPortfolio..CovidDeaths dea
JOIN CovidPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

)
SELECT *, (RollingVaccinationCount/Population)*100
FROM PopsvsVac