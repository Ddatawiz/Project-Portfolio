/*select * from covid_death
order by 3,4

select * from covid_vaccinations
order by 3,4*/

--select Datathat we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from covid_death
order by 1,2


--Looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DEATH_PERCENTAGE
from covid_death
where location like 'Africa'
order by 1,2

-- Total cases vs the population

select location, date, MAX(total_cases) AS highestinfectioncount, population, (total_cases/population)*100 as Total_population
from covid_death
where location like '%Nigeri%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select location, population, MAX(cast(total_cases as int)) AS highestinfectioncount, MAX((total_cases/population))*100 as PercentPopulationInfected
from covid_death
--where location like '%Nigeri%'
Where continent is not null and Total_deaths is not null
GROUP by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From covid_death
--Where location like '%Nigeri%'
Where continent is not null and TotalDeathCount is not null
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Contintents with the highest death count per population

Select covid_death.continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From covid_death
--Where location like '%Nigeri%'
Where continent is NOT null
Group by covid_death.continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covid_death
--Where location like 'Nigeria'
where continent is not null 
--Group By date
order by 1,2


--Looking at Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, cast(dea.population as int), vac.new_vaccinations
FROM covid_death dea
join covid_vaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3
 
 -- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, cast(dea.population as int), vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_death dea
Join covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, cast(dea.population as int), vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_death dea
Join covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated
Create TEMP Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_death dea
Join covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_death dea
Join covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Create View Total_population as
SELECT dea.continent, dea.location, dea.date, cast(dea.population as int), vac.new_vaccinations
FROM covid_death dea
join covid_vaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

select * from PercentPopulationVaccinated

select * from Total_population