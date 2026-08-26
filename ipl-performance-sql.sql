/* 
PROJECT: IPL DATA ANALYSIS
DATASET: matches + deliveries
AUTHOR: Katta Sai Hemanth
*/


create database ipl_project;
use ipl_project;

select count(*) from matches;
select count(*) from deliveries;
SELECT * FROM deliveries ;
SELECT * FROM matches limit 5;
select count(distinct batter) from deliveries;
select count(distinct bowler) from deliveries;


-- this query tells the total wins of teams
select winner,count(*) as total_wins from matches
group by winner
order by total_wins desc;

-- this query tells no of times a player won POTM 
select player_of_match,count(*) no_of_times from matches
group by player_of_match
having no_of_times >=3
order by no_of_times desc;

-- this query tells no of matches played per season
select season,count(*) as no_of_matches from matches
group by season
order by season;

-- this query tells top 3 venues of most matches played
select venue,count(*) as matches_played from matches
group by venue
order by matches_played desc limit 3;


/* This query calculates the top 5 batters by total runs*/
select batter,sum(batsman_runs) as total_runs from deliveries
group by batter
order by total_runs desc limit 5;

-- this query tells top 10 bowler per wickets
select bowler,count(dismissal_kind) as no_of_wickets from deliveries
where dismissal_kind in ('bowled','caught')
group by bowler
order by no_of_wickets desc limit 10;

-- this query tells how many times the toss winner also won the match vs lost.
select result, count(*) as matches from(
select 
case when toss_winner = winner then "toss winner won"
else "toss winner lost" end as result from matches) as toss_result
group by result
order by matches desc;


-- Display batters whose total runs are greater than the average total runs of all batters
with TR as (SELECT batter,sum(batsman_runs) AS total_runs FROM deliveries
GROUP BY batter),
AR as( select avg(total_runs) as avg_runs from TR)
select * from TR
where total_runs > (select avg_runs from AR)
order by total_runs desc;

-- this query create a category for which batters belong
with BM as(select batter,sum(batsman_runs) as total_runs from deliveries group by batter),
CT as(select batter,total_runs,case when total_runs > 3000 then 'ELITE'
when total_runs between 1000 and 3000 then 'GOOD'
else 'DEVELOPING' end as category from BM)
select * from CT
order by total_runs desc;

-- this query tells highest runs of a team per single match over all seasons
with match_runs as(select match_id,batting_team,sum(total_runs) as runs from deliveries
group by match_id,batting_team)
select m.season,mr.match_id,(mr.batting_team),mr.runs from match_runs as mr 
join matches as m on mr.match_id = m.id 
order by  mr.runs desc;

-- top 5 bastman in all seasons
with tb as (
select m.season,d.batter,sum(d.batsman_runs) as total_runs from deliveries as d
join matches as m on d.match_id = m.id 
group by m.season,d.batter),
ranked as (select season,batter,total_runs,
rank() over(partition by season order by total_runs desc) as top_batters from tb)
select season,batter,total_runs,top_batters from ranked
where top_batters <=5;

-- wins of a single teams per season comaprision
with winners as(select season,winner as team,count(*) as win from matches
group by season,team),
previous as(select season,team,win,
lag(win) over(partition by team order by season)as last_year from winners)
select season,team,win from previous;

-- all matches where the team batting second won despite chasing a target above 180 runs.
select id,season,winner,target_runs as target_chased from matches
where target_runs > 180 and result = 'wickets';

WITH top_batsmen AS (
SELECT batter, SUM(batsman_runs) AS total_runs FROM deliveries
GROUP BY batter 
ORDER BY total_runs DESC LIMIT 50),
top_bowlers AS (
SELECT bowler, SUM(is_wicket) AS total_wickets FROM deliveries
GROUP BY bowler
ORDER BY total_wickets DESC LIMIT 50)
SELECT b.batter AS player,b.total_runs,w.total_wickets
FROM top_batsmen b
JOIN top_bowlers w ON b.batter = w.bowler
ORDER BY total_runs DESC;
