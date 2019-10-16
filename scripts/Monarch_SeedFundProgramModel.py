# -*- coding: utf-8 -*-
"""
Created on Wed Nov  8 13:22:51 2017

@author: Erik
"""

import numpy as np
import pandas as pd
#from scipy import stats

class Scenario(object):
    def __init__(self, name, seed, admin_pct, fundr_eff):
        self.name = name
        self.seed = seed
        self.admin_pct = admin_pct
        self.fundr_eff = fundr_eff
        
    def getYears(self):
        return self.years
    
    def getSeed(self):
        return self.seed
    
    def getGoal(self):
        return self.goal
        
    def getProjectApps(self, budget):
        return budget/10000
        
class Region(Scenario):
    def __init__(self, name, goal, acres_u, acres_sd, uplift_u, uplift_sd,
                 support_cost_u, support_cost_sd, imp_cost_u, imp_cost_sd, 
                 maint_cost_u, maint_cost_sd, rent):
        self.name = str(name)
        self.goal = goal
        self.acres_u = acres_u
        self.acres_sd = acres_sd
        self.uplift_u = uplift_u
        self.uplift_sd = uplift_sd
        self.support_cost_u = support_cost_u
        self.support_cost_sd = support_cost_sd
        self.imp_cost_u = imp_cost_u
        self.imp_cost_sd = imp_cost_sd
        self.maint_cost_u = maint_cost_u
        self.maint_cost_sd = maint_cost_sd
        self.rent = rent
    
    def __repr__(self):
        return "Region " + self.name
    
    def getGoal(self):
        return self.goal
    
    def getAcres (self):
        min_x, max_x = 0, 10000
        x = 0
        while x <= min_x or x >= max_x:
            x = np.random.normal(self.acres_u, self.acres_sd, 1)[0]
        return x
    
    def getUplift (self):
        min_x, max_x = 0, 1        
        x = 0
        while x <= min_x or x >= max_x:
            x = np.random.normal(self.uplift_u, self.uplift_sd, 1)[0]
        return x
    
    def getSupport_Cost (self):
        min_x, max_x = 0, 100000
        x = 0
        while x <= min_x or x >= max_x:
            x = np.random.normal(self.support_cost_u, 
                                 self.support_cost_sd, 1)[0]
        return x
    
    def getImp_Cost (self):
        min_x, max_x = 0, 100000
        x = 0
        while x <= min_x or x >= max_x:
            x = np.random.normal(self.imp_cost_u, self.imp_cost_sd, 1)[0]
        return x
    
    def getMaint_Cost (self):
        min_x, max_x = 0, 100000
        x = 0
        while x <= min_x or x >= max_x:
            x = np.random.normal(self.maint_cost_u, self.maint_cost_sd, 1)[0]
        return x
    
    def getRent(self):
        return self.rent
    
class Project(object):
    projectID = 0
    
    def __init__(self, term, acres, uplift, support_cost, imp_cost, maint_cost, rent):
        self.ID = Project.projectID
        self.term = term
        self.acres = acres
        self.uplift = uplift
        self.facres = acres * uplift
        self.support_cost = support_cost
        self.imp_cost = imp_cost
        self.maint_cost = maint_cost
        self.rent = rent
        self.cost = support_cost + imp_cost + term * (maint_cost + rent)
        self.efficiency = self.cost/self.facres
        Project.projectID += 1
        
    def __repr__(self):
        return "Project " + str(self.ID) + "; " + str(self.facres) + " F-Acres" \
    + "; $" + str(round(self.efficiency,2)) + " per F-Acre"

def resetProjectID():
    Project.projectID = 0
            
def createProjects(number, region):
    projects = []
    for i in range(number):
        term = 5
        acres = region.getAcres()
        uplift = region.getUplift()
        support_cost = region.getSupport_Cost()
        imp_cost = region.getImp_Cost()
        maint_cost = region.getMaint_Cost()
        rent = region.getRent()
        projects.append(Project(term, acres, uplift, support_cost, imp_cost, 
                                maint_cost, rent))
    return projects
        
def sortProjects(projects):
    return sorted(projects, key = lambda project: project.efficiency)

def fundProgram (expenses, eval_scenario):
    admin = expenses * eval_scenario.admin_pct
    fundr = expenses * eval_scenario.fundr_eff
    program_budget = expenses - admin - fundr
    return admin, fundr, program_budget
    
def fundProjects(projects, goal, program_budget):
    # consider adding year and acquisition costs here
    selected_projects = []
    facres = 0
    program_cost = 0
    projects_remain = len(projects)
    while facres <= goal and projects_remain > 0:
        project = projects[0]
        selected_projects.append(project)
        facres += project.facres
        program_cost += project.cost
        projects_remain -= 1
        projects = projects[1:]
    return selected_projects, facres, program_cost

def evalRegionScenario(region, eval_scenario):
    """Assumes regions is a list of objects of the class Regions and
    eval_scenario is of the class Scenario."""
    resetProjectID()
    #initialize program totals
    investment_total = 0
    periods = 0
    admin_exp = []
    fundr_exp = []
    program_exp = []
    funded_projects = []
    facres_per_period = []
    
    admin_total = 0
    fundr_total = 0
    program_total = 0
    facres_total = 0
    
    unfunded_projects = []
    funded_projects = []
    
    #obtain seed funding 
    I = eval_scenario.getSeed()
    
    # fund projects until f-acre goal for each region is reached
    region_goal = region.getGoal()
    while facres_total <= region_goal:
        periods += 1
        investment_total += I
        #fund program expenses
        admin, fundr, program_budget = fundProgram (I, eval_scenario)
        admin_exp.append(admin)
        admin_total += admin
        fundr_exp.append(fundr)
        fundr_total += fundr
        program_exp.append(program_budget)
        program_total += program_budget
        #fund support of existing projects
        
        #solicit projects
        num_projects = int(eval_scenario.getProjectApps(I))
        applied_projects = createProjects(num_projects, region)
        unfunded_projects.extend(applied_projects)
        sorted_projects = sortProjects(unfunded_projects)
        goal = region_goal - facres_total
        selected_projects, facres, program_cost = fundProjects(sorted_projects,
                                                       goal, program_budget)
        funded_projects.extend(selected_projects)
        facres_total += facres
        program_total += program_cost
    
    total_cost = (admin_total + fundr_total + program_total)/(10**6)
    return facres_total, total_cost, periods, program_exp, funded_projects
        
# Run simulation
#Create Region 'South Central'
name = "South_Central"
goal = 0.4*(10**6)
acres_u, acres_sd = 8750, 2000
uplift_u, uplift_sd = .4, .25
support_cost_u, support_cost_sd = 4700, 100 
imp_cost_u, imp_cost_sd = 12, 2
maint_cost_u, maint_cost_sd = 4, .5
rent = 0
South_Central = Region(name, goal, acres_u, acres_sd, uplift_u, uplift_sd, 
                       support_cost_u, support_cost_sd, imp_cost_u, 
                       imp_cost_sd, maint_cost_u, maint_cost_sd, rent)
del(name, goal, acres_u, acres_sd, uplift_u, uplift_sd, support_cost_u,
    support_cost_sd, imp_cost_u, imp_cost_sd, maint_cost_u, maint_cost_sd,
    rent)

#Create Region 'South Central'
name = "North_Central"
goal = 0.4*(10**6)
acres_u, acres_sd = 1000, 250
uplift_u, uplift_sd = .6, .3
support_cost_u, support_cost_sd = 4700, 100
imp_cost_u, imp_cost_sd = 1000, 100
maint_cost_u, maint_cost_sd = 100, 10
rent = 1000
North_Central = Region(name, goal, acres_u, acres_sd, uplift_u, uplift_sd, 
                       support_cost_u, support_cost_sd, imp_cost_u, 
                       imp_cost_sd, maint_cost_u, maint_cost_sd, rent)
del(name, goal, acres_u, acres_sd, uplift_u, uplift_sd, support_cost_u,
    support_cost_sd, imp_cost_u, imp_cost_sd, maint_cost_u, maint_cost_sd,
    rent)

#Create Scenario1
# PUT STUFF HERE:
name = "Scenario1"
seed = .1*(10**6)
admin_pct = 0.06
fundr_eff = 0.14

Scenario1 = Scenario(name, seed, admin_pct, fundr_eff)
del (name, seed, admin_pct, fundr_eff)

#Run scenario
regions = [South_Central, North_Central]
scenario = Scenario1
region_metrics = []
funded_projects = []
for region in regions:
    facres_total, program_cost, periods, program_exp, region_funded_projects = \
    evalRegionScenario (region, scenario)
    region_metrics.append(region.name)
    region_metrics.append(facres_total)
    region_metrics.append(program_cost)
    region_metrics.append(periods)
    funded_projects.append(region_funded_projects)

print (region_metrics[:4], region_metrics[4:])