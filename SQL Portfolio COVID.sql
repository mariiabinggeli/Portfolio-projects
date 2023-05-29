SELECT *
FROM Portfolioprojectcovid.dbo.CovidDeaths$
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM Portfolioprojectcovid.dbo.CovidVaccinations$
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases,total_deaths
FROM Portfolioprojectcovid.dbo.CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contracting it in your country
SELECT Location, date, total_cases, total_deaths, (TRY_CAST(total_deaths AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(total_cases AS NUMERIC(10, 2)), 0))*100 AS DeathPercentage
FROM Portfolioprojectcovid.dbo.CovidDeaths$
WHERE location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- shows what percentage of population got COVID 

SELECT Location, date, Population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM Portfolioprojectcovid.dbo.CovidDeaths$
WHERE location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population

SELECT Location, Population,MAX (total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS HighestPercentPopulationInfected
FROM Portfolioprojectcovid.dbo.CovidDeaths$
GROUP BY Location, Population
order by HighestPercentPopulationInfected 

--Showing the countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolioprojectcovid.dbo.CovidDeaths$
WHERE continent is not null

GROUP BY Location
order by TotalDeathCount desc

-- Showing continents with the highest deaths count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolioprojectcovid.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolioprojectcovid.dbo.CovidDeaths$
where continent is not null 
order by 1,2


-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioprojectcovid..CovidDeaths$ dea
Join Portfolioprojectcovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioprojectcovid..CovidDeaths$ dea
Join Portfolioprojectcovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioprojectcovid..CovidDeaths$ dea
Join Portfolioprojectcovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for visualizations
CREATE VIEW PercentpopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioprojectcovid..CovidDeaths$ dea
Join Portfolioprojectcovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

SELECT *
FROM PercentpopulationVaccinated
