SELECT *
FROM CovidDeaths
Where continent is NOT Null
ORDER BY 3,4

SELECT*
FROM CovidVaccinations
Where continent is NOT Null
ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date,  total_cases, new_cases, total_deaths, population
FROM CovidDeaths
Where continent is NOT Null
Where continent is NOT Null
ORDER BY 1,2


--Looking at the Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract Covid in your country

SELECT location, date,  total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location Like '%states%'
Where continent is NOT Null
ORDER BY 1,2




--Looking at the total cases vs the population

SELECT location, date,  Population, total_cases, (total_cases/population)*100 as InfectionPerentage
FROM CovidDeaths
WHERE location Like '%states%'
Where continent is NOT Null
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
FROM CovidDeaths
--WHERE location Like '%states%'
Where continent is NOT Null
Group BY Location, Population
ORDER BY PercentOfPopulationInfected DESC



--Showing the countries with the highest death count per population


SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
FROM CovidDeaths
--WHERE location Like '%states%'
Where continent is NOT Null
Group BY Location, Population
ORDER BY PercentOfPopulationInfected DESC



--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location Like '%states%'
Where continent is NOT Null
Group BY Location
ORDER BY TotalDeathCount DESC



--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the continents with the highest death count per population



SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location Like '%states%'
Where continent is not Null
Group BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location Like '%states%'
WHERE continent is NOT Null
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location
	, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
Order By 2,3



--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location
	, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--Order By 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE 

DROP TABLE if exists #PercentPoplationVaccinated
CREATE TABLE #PercentPoplationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
Insert INTO #PercentPoplationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location
	, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--Order By 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPoplationVaccinated


--Creating View to store data for later visulizations

CREATE View PercentPoplationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location
	, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--Order By 2,3