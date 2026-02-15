
-- Query 1: Create MusicVideo Table
-- MusicVideo is a subclass of Track (generalization relationship)
CREATE TABLE MusicVideo (
    TrackId INTEGER PRIMARY KEY,
    VideoDirector TEXT NOT NULL,
    FOREIGN KEY (TrackId) REFERENCES tracks(TrackId)
        ON DELETE CASCADE
);

-- Query 2: Insert 10 videos
INSERT INTO MusicVideo (TrackId, VideoDirector) VALUES
(1, 'Spike Jonze'),
(2, 'Hype Williams'),
(3, 'Dave Meyers'),
(4, 'Joseph Kahn'),
(5, 'Mark Romanek'),
(6, 'Chris Cunningham'),
(7, 'Michel Gondry'),
(8, 'Anton Corbijn'),
(9, 'Jake Nava'),
(10, 'Sophie Muller');

-- Query 3: Insert video for Voodoo track using subquery
INSERT INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'David Fincher'
FROM tracks
WHERE Name = 'Voodoo';

-- Query 4: Tracks with accented vowels (á, é, í, ó, ú)
SELECT Name
FROM tracks
WHERE Name LIKE '%á%'
   OR Name LIKE '%é%'
   OR Name LIKE '%í%'
   OR Name LIKE '%ó%'
   OR Name LIKE '%ú%';

-- Query 5: Albums with their artists and track counts
-- Shows which albums have the most songs
SELECT 
    ar.Name AS ArtistName,
    al.Title AS AlbumTitle,
    COUNT(t.TrackId) AS NumberOfTracks,
    SUM(t.Milliseconds) / 60000.0 AS TotalMinutes
FROM artists ar
JOIN albums al ON ar.ArtistId = al.ArtistId
JOIN tracks t ON al.AlbumId = t.AlbumId
GROUP BY al.AlbumId, ar.Name, al.Title
ORDER BY NumberOfTracks DESC
LIMIT 20;

-- Query 6: Employee sales performance
-- Shows which employees are supporting the most valuable customers
SELECT 
    e.FirstName || ' ' || e.LastName AS EmployeeName,
    e.Title,
    COUNT(DISTINCT c.CustomerId) AS CustomersSupported,
    COUNT(i.InvoiceId) AS TotalSales,
    SUM(i.Total) AS TotalRevenue,
    AVG(i.Total) AS AvgSaleAmount
FROM employees e
JOIN customers c ON e.EmployeeId = c.SupportRepId
JOIN invoices i ON c.CustomerId = i.CustomerId
GROUP BY e.EmployeeId, e.FirstName, e.LastName, e.Title
ORDER BY TotalRevenue DESC;

-- Bonus Query 7: Customers who purchased above-average length tracks
-- Excluding tracks over 15 minutes
SELECT DISTINCT 
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS CustomerName,
    c.Country,
    c.Email
FROM customers c
JOIN invoices i ON c.CustomerId = i.CustomerId
JOIN invoice_items ii ON i.InvoiceId = ii.InvoiceId
JOIN tracks t ON ii.TrackId = t.TrackId
WHERE t.Milliseconds > (SELECT AVG(Milliseconds) FROM tracks)
  AND t.Milliseconds <= 15 * 60 * 1000
ORDER BY CustomerName;

-- Bonus Query 8: Tracks not in the top 5 longest-duration genres
SELECT 
    t.Name AS TrackName,
    g.Name AS GenreName,
    al.Title AS AlbumName,
    t.Milliseconds / 60000.0 AS DurationMinutes
FROM tracks t
JOIN genres g ON t.GenreId = g.GenreId
JOIN albums al ON t.AlbumId = al.AlbumId
WHERE t.GenreId NOT IN (
    SELECT g2.GenreId
    FROM genres g2
    JOIN tracks t2 ON g2.GenreId = t2.GenreId
    GROUP BY g2.GenreId
    ORDER BY SUM(t2.Milliseconds) DESC
    LIMIT 5
)
ORDER BY g.Name, t.Name
LIMIT 50;