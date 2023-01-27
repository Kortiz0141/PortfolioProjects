---DATA Feb 2, 2020 to Jan 25, 2023

Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at total cases versus total deaths
--Shows likelihood of death upon contraction of covid in the U.S.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where location  like '%states%'
and continent is not null
order by 1,2

--Looking at total cases versus population
--Show was percentage of the population got covid
Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location  like '%states%'
and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Showing countries with the highest death count per population
Select location, max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Let's break things down by continent
--Showing continents with the highest death count per population
Select continent, max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated 
(
Continent nvarchar(255), 
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated
