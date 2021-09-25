
---Cheching if the data was correctly imported--------

SELECT * 
	FROM project_covid..CovidDeath$
	WHERE continent is not null
	ORDER BY 3, 4
;

SELECT * 
	FROM project_covid..CovidVaccination$
	WHERE continent is not null
	ORDER BY 1, 2
;


-----Starting My Analysis of covid in Nigeria as at 23/09/2021----------------

SELECT location, date, population, total_cases, total_deaths
	FROM project_covid..CovidDeath$
	WHERE continent is not null
	ORDER BY 1, 2
;

--------Total Cases Vs Total Deaths in  Nigeria------------
--------Showing likelyhood of dying if you contact covid in Nigeria--------

SELECT location, date, population, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
	FROM project_covid..CovidDeath$
	WHERE location like '%Nigeria%'
	ORDER BY 1, 2
;

-------Looking at the Total Cases Vs The Population-------

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulation
	FROM project_covid..CovidDeath$
	WHERE location like '%Nigeria%'
	ORDER BY 1, 2
;

-----Looking at counties with higher infection rate to population-----

SELECT location, population, max(total_cases) AS TotalCase, max((total_cases/population))*100 as PercentagePopulationInfected
	FROM project_covid..CovidDeath$
	WHERE location like '%Nigeria%'
	GROUP BY location, population
	ORDER BY PercentagePopulationInfected DESC
;


-----------This is showig the country with the higest death count per population-----
SELECT continent, population, max(total_deaths) AS TotalDeaths, max((total_deaths/population))*100 as PercentagePopulationDeath
	FROM project_covid..CovidDeath$
	WHERE location like '%Nigeria%'
	GROUP BY continent, population
	ORDER BY PercentagePopulationDeath DESC
;

-------------------This is showig the higest death by continent-----
SELECT continent, max(cast(total_deaths as int)) AS TotalDeathCount
	FROM project_covid..CovidDeath$
    WHERE continent is not null
	GROUP BY continent
	ORDER BY TotalDeathCount DESC
;

-------------------This is showig the Total Cases by continent-----
SELECT location, max(cast(total_cases as int)) AS TotalCaseCount
	FROM project_covid..CovidDeath$
    WHERE continent is null
	GROUP BY location
	ORDER BY TotalCaseCount DESC
;


-----------GLOBAL TOTAL CASES------


SELECT  SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeath, SUM(CAST(new_deaths as int))/SUM(new_cases)*100
    AS DeathPercentage
	FROM project_covid..CovidDeath$
	WHERE continent is not null
	ORDER BY 1, 2
;

-------Joining two data tables (COVIDDEATH AND COVIDVACCINATION)

SELECT * 
	FROM project_covid..CovidDeath$ cds
	JOIN project_covid..CovidVaccination$ cvs
	ON cds.location = cvs.location
	and cds.date = cds.date
;


-------Total  Population Vs Vaccination)

SELECT cds.continent, cds.location, cds.date, cds.population, cvs.new_vaccinations
	FROM project_covid..CovidDeath$ cds
	JOIN project_covid..CovidVaccination$ cvs
	ON cds.location = cvs.location
	and cds.date = cds.date
	WHERE cds.continent is not null
	ORDER BY 2,3

	-------Total  Population Vs Vaccination)

SELECT cds.continent, cds.location, cds.date, cds.population, cvs.new_vaccinations,
	SUM(cast(cvs.new_vaccinations as int)) OVER (Partition by cds.location Order by cds.location, 
	cds.date) as RollingPeopleVaccinated
	FROM project_covid..CovidDeath$ cds
	JOIN project_covid..CovidVaccination$ cvs
	ON cds.location = cvs.location
	and cds.date = cvs.date
	WHERE cds.continent is not null
	ORDER BY 2,3
;

----------USE CTE-------------

-------------Temp Table--------------

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT cds.continent, cds.location, cds.date, cds.population, cvs.new_vaccinations,
	SUM(cast(cvs.new_vaccinations as int)) OVER (Partition by cds.location Order by cds.location, 
	cds.date) as RollingPeopleVaccinated
	FROM project_covid..CovidDeath$ cds
	JOIN project_covid..CovidVaccination$ cvs
	ON cds.location = cvs.location
	and cds.date = cvs.date
	WHERE cds.continent is not null
	
	SELECT *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinatedPeople
FROM #PercentPopulationVaccinated
;



---------------------Creating view for Visuallization, which can be found in the view folder in our database---------------

CREATE View PercentPopulationVaccinated as
SELECT cds.continent, cds.location, cds.date, cds.population, cvs.new_vaccinations,
	SUM(cast(cvs.new_vaccinations as int)) OVER (Partition by cds.location Order by cds.location, 
	cds.date) as RollingPeopleVaccinated
	FROM project_covid..CovidDeath$ cds
	JOIN project_covid..CovidVaccination$ cvs
	ON cds.location = cvs.location
	and cds.date = cvs.date
	WHERE cds.continent is not null
;

---------------checking my created view-----------------------
select * from PercentPopulationVaccinated