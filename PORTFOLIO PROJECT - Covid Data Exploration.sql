/*

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select*
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- Select initial Data

Select Location, date,total_cases, new_cases, total_deaths,population 
From PortfolioProject..CovidDeaths
and continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like 'Ecuador' --'%states%'
and continent is not null
order by 1,2


-- Looking Total Cases Vs Population
-- Shows what percentage of population infected with Covid

Select Location, date,population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like 'Ecuador' --'%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location,population,MAX(total_cases) as HighestInfectionCountry, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like 'Ecuador' --'%states%'
Group by Location,population
order by PercentagePopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like 'Ecuador' --'%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- ANALYSIS BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent ,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent 
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Ecuador' --'%states%'
where continent is not null
--Group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine
-- USE CTE (Common Table Expression)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject ..CovidDeaths dea
Join PortfolioProject ..CovidVaccinations vac
	ON dea.location =vac.location 
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- TEMP TABLE
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

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
, SUM (convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject ..CovidDeaths dea
Join PortfolioProject ..CovidVaccinations vac
	ON dea.location =vac.location 
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select*,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 

-- Creating view to store data for visualizations

go
CREATE VIEW PercentPopVacc AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject ..CovidDeaths dea
Join PortfolioProject ..CovidVaccinations vac
	ON dea.location =vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3


