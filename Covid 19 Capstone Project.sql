--select statement
Select * From dbo.covidDeaths
Order By 3, 4;


--select location, date, total_cases, total_deaths, population
Select location, date, total_cases, total_deaths, population
From dbo.covidDeaths
Order By 1, 2;

--total deaths / total cases
--shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0)) * 100 as deathPercentage
From covidDeaths
where location = 'india'
and continent is not null
Order By 1, 2; 

--total cases / population
--shows what percentage of peoples are contracted with covid
Select location, date, population, total_cases, (total_cases / population) * 100 as PercentagePopulationInfected
From covidDeaths
where location = 'india'
and continent is not null
Order by 1, 2;

--countries with highest infection rate comparede to population
Select location, population, Sum(total_cases) as InfectedCount, Max((total_cases / population)) * 100 as PercentagePopulationInfected
From covidDeaths
where continent is not null
group by location, population
Order by PercentagePopulationInfected desc;

--countries with highest death count per population
Select location, population, Max(total_deaths) as totalDeaths, Max((total_deaths/population)*100) as PercentageDeathCount
From covidDeaths
Where continent is not null
Group By location, population
Order By PercentageDeathCount Desc;

--continents with highest death count per population
Select location, population, Max(total_deaths) as totalDeaths, Max((total_deaths/population)*100) as PercentageDeathCount
From covidDeaths
Where continent is null
Group By location, population
Order By PercentageDeathCount Desc;

--Global Numbers
Select  Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, Sum(new_deaths)/SUM(Nullif(new_cases,0))*100 as DeathPercentage
From covidDeaths
where continent is not null
--group by date
order by 1, 2;

--Total Population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order By dea.location, dea.date) as rollingPeopleVaccinatedCount
FROM covidDeaths dea
Join covidVaccinations as vac
	On dea.location = vac.location And dea.date = vac.date
Where dea.continent is not null
Order By 2, 3;

--USE CTE
With PopvsVac(continent, location, date, population, new_vaccinations, rollingPeopleVaccinatedCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order By dea.location, dea.date) as rollingPeopleVaccinatedCount
FROM covidDeaths dea
Join covidVaccinations as vac
	On dea.location = vac.location And dea.date = vac.date
Where dea.continent is not null
--Order By 2, 3
)
Select * ,(rollingPeopleVaccinatedCount / population) * 100 From PopvsVac where location = 'india';

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order By dea.location, dea.date) as rollingPeopleVaccinatedCount
FROM covidDeaths dea
Join covidVaccinations as vac
	On dea.location = vac.location And dea.date = vac.date
Where dea.continent is not null;

Select * ,(RollingPeopleVaccinated / Population) * 100 From #PercentPopulationVaccinated where location = 'india';

-- Creating view to store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order By dea.location, dea.date) as rollingPeopleVaccinatedCount
FROM covidDeaths dea
Join covidVaccinations as vac
	On dea.location = vac.location And dea.date = vac.date
Where dea.continent is not null

Select * From PercentPopulationVaccinated;






