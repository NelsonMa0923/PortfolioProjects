/*

Covid 19 Data Exploration


Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..[CovidDeaths 3 Corrected(CSV)]
where continent is not null
Order by 3,4


--Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[CovidDeaths 3 Corrected(CSV)]
where continent is not null
Order by 1



-- Comparing Total Cases vs Total Deaths
-- This query shows the percentage of people dying from covid in United States
Select location, date, total_cases, total_deaths, (Convert(float,total_deaths)/Nullif(Convert(float,total_cases),0))*100 AS Death_percentage
From PortfolioProject..[CovidDeaths 3 Corrected(CSV)]
Where location like '%states%' and continent is not null
Order by 1



-- Total Cases vs Population(United States)
-- This shows the percentage of population got covid in United States
Select location, date, population, total_cases, (Nullif(Convert(float,total_cases),0)/population)*100 AS Covid_Infected_percentage
From PortfolioProject..[CovidDeaths 3 Corrected(CSV)]
Where location like '%states%'
and continent is not null
Order by 1



--Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((Nullif(Convert(float,total_cases),0)/Nullif(convert(float,population),0)))*100 as PercentPopulationInfected
From PortfolioProject..[CovidDeaths 3 Corrected(CSV)]
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc



--Looking at Countries with Highest Infection Rate compared to Population (Accroding to date)
Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((Nullif(Convert(float,total_cases),0)/Nullif(convert(float,population),0)))*100 as PercentPopulationInfected
From PortfolioProject..[CovidDeaths 3 Corrected(CSV)]
where continent is not null
Group by Location, Population, date
order by PercentPopulationInfected desc



-- Showing the countries with Highest Death Count per Population
Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..[CovidDeaths 3 Corrected(CSV)]
where continent!=' '
Group by Location
order by TotalDeathCount desc



--Showing the Continents with Highest Death Count per population 
Select continent, Sum(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..[CovidDeaths 3 Corrected(CSV)]
where continent!=' '
Group by continent
order by TotalDeathCount desc



-- Global Numbers
Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM((Nullif(Convert(float,new_deaths),0)))/sum((Nullif(convert(float,new_cases),0)))*100 as DeathPercentage
From PortfolioProject..[CovidDeaths 3 Corrected(CSV)]
where continent!=' '
order by 1,2



--looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum((Nullif(Convert(float,vac.new_vaccinations),0))) over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination
From PortfolioProject..[CovidDeaths 3 Corrected(CSV)] dea
join PortfolioProject..[CovidVaccinations 3 Corrected(CSV)] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent!=' '
order by 2,3



--Use CTE
with PopvsVac (Continent, location, date, population, new_vaccinations, Rolling_Vaccination)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum((Nullif(Convert(float,vac.new_vaccinations),0))) over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination
From PortfolioProject..[CovidDeaths 3 Corrected(CSV)] dea
join PortfolioProject..[CovidVaccinations 3 Corrected(CSV)] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent!=' '
)
Select*, (Rolling_Vaccination/Population)*100
From PopvsVac



--Temp Table
Drop Table if exists #Perent_Population_Vaccinated
Create Table #Perent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
new_vaccinations float,
Rolling_Vaccination float
)

Insert into #Perent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum((Nullif(Convert(float,vac.new_vaccinations),0))) over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination
From PortfolioProject..[CovidDeaths 3 Corrected(CSV)] dea
join PortfolioProject..[CovidVaccinations 3 Corrected(CSV)] vac
	on dea.location = vac.location
	and dea.date = vac.date

Select*, (Rolling_Vaccination/Population)*100
From #Perent_Population_Vaccinated



--Creating View to store data for later visulization
Create View Perent_Population_Vaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum((Nullif(Convert(float,vac.new_vaccinations),0))) over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination
From PortfolioProject..[CovidDeaths 3 Corrected(CSV)] dea
join PortfolioProject..[CovidVaccinations 3 Corrected(CSV)] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent!=' '

select* 
from Perent_Population_Vaccinated

