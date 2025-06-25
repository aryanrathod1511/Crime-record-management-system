CREATE SCHEMA CRMS;

SET search_path TO CRMS;

--1. Criminal Table
CREATE TABLE criminal ( 
    criminal_id VARCHAR(5) PRIMARY KEY, 
    name VARCHAR(50), 
    alias VARCHAR(25), 
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F', 'O')), 
    dob DATE NOT NULL, 
    gov_id VARCHAR(15) UNIQUE,  
    base_address TEXT, 
    city VARCHAR(15) NOT NULL, 
    district VARCHAR(15) NOT NULL, 
    state VARCHAR(15) NOT NULL 
);


--2. Crime Table
CREATE TABLE crime ( 
    fir_no VARCHAR(5) PRIMARY KEY, 
    type_of_crime VARCHAR(15) NOT NULL, 
    status VARCHAR(15) DEFAULT 'Open', 
    date_and_time TIMESTAMP NOT NULL, 
    description TEXT NOT NULL, 
    police_station VARCHAR(15) NOT NULL, 
    city VARCHAR(15) NOT NULL, 
    state VARCHAR(15) NOT NULL 
);	


--3. Evidence Table(Multivalue attribute of crime table)
CREATE TABLE evidence ( 
    fir_no VARCHAR(5), 
    evidences TEXT NOT NULL, 
    PRIMARY KEY (fir_no, evidences), 
    FOREIGN KEY (fir_no) REFERENCES crime(fir_no) 
		ON DELETE CASCADE ON UPDATE CASCADE 
); 


--4. Commits Table (Many-to-Many : criminal - crime)
CREATE TABLE commits ( 
    criminal_id VARCHAR(5), 
    fir_no VARCHAR(5), 
    PRIMARY KEY (criminal_id, fir_no), 
    FOREIGN KEY (criminal_id) REFERENCES criminal(criminal_id) 
		ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (fir_no) REFERENCES crime(fir_no) 
		ON DELETE CASCADE ON UPDATE CASCADE 
); 


--5. Officer Table
CREATE TABLE officer ( 
    badge_no VARCHAR(5) PRIMARY KEY, 
    name VARCHAR(25) NOT NULL, 
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F', 'O')), 
    jurisdiction VARCHAR(15) NOT NULL, 
    department VARCHAR(15) NOT NULL, 
    rank VARCHAR(15) 
); 


--6. Officer-Contact Table (Multivalue attribute of officer table)
CREATE TABLE officer_contact ( 
    badge_no VARCHAR(5), 
    contact_no VARCHAR(10), 
    PRIMARY KEY (badge_no, contact_no), 
    FOREIGN KEY (badge_no) REFERENCES officer(badge_no) 
		  ON DELETE CASCADE ON UPDATE CASCADE
); 


--7. InvestigatedBy table (Many-to-Many : officer - crime)
CREATE TABLE investigated_by ( 
    fir_no VARCHAR(5), 
	  badge_no VARCHAR(5), 
	  PRIMARY KEY (fir_no, badge_no), 
	  FOREIGN KEY (fir_no) REFERENCES crime(fir_no) 
		  ON DELETE CASCADE ON UPDATE CASCADE, 
	  FOREIGN KEY (badge_no) REFERENCES officer(badge_no) 
		  ON DELETE CASCADE ON UPDATE CASCADE 
); 


--8. Case Table
CREATE TABLE "case" ( -- "case" because simple case give error
    case_id VARCHAR(5) PRIMARY KEY, 
    status VARCHAR(15) DEFAULT 'Pending', 
    verdict TEXT, 
    verdict_date DATE, 
    fir_no VARCHAR(5) NOT NULL, 
    FOREIGN KEY (fir_no) REFERENCES crime(fir_no) 
		ON DELETE CASCADE ON UPDATE CASCADE 
); 	


--9. Prisoner Table
CREATE TABLE prisoners ( 
    prisoner_id VARCHAR(5) PRIMARY KEY, 
    prisoner_name VARCHAR(50) NOT NULL, 
    prison_name VARCHAR(50) NOT NULL, 
    prison_cell_no VARCHAR(15) NOT NULL, 
    status VARCHAR(15) NOT NULL, 
    release_date DATE, 
    sentence_duration INT CHECK (sentence_duration > 0) -- In days 
); 


--10. Convicts Table (Many-to-Many : case - prisoners)
CREATE TABLE convicts ( 
	  case_id VARCHAR(5), 
	  prisoner_id VARCHAR(5), 
	  PRIMARY KEY (case_id, prisoner_id), 
	  FOREIGN KEY (case_id) REFERENCES "case"(case_id) 
		  ON DELETE CASCADE ON UPDATE CASCADE, 
	  FOREIGN KEY (prisoner_id) REFERENCES prisoners(prisoner_id) 
		  ON DELETE CASCADE ON UPDATE CASCADE 
);


--11. Victim Table
CREATE TABLE victim ( 
    victim_no VARCHAR(5) PRIMARY KEY, 
    name VARCHAR(50) NOT NULL, 
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F', 'O')), 
    age INT CHECK (age > 0), 
	  gov_id VARCHAR(15) UNIQUE 
); 


--12. Victim-Contact Table (Multivalue attribute of victim table)
CREATE TABLE victim_contact ( 
    victim_no VARCHAR(5), 
    contact_no VARCHAR(10), 
    PRIMARY KEY (victim_no, contact_no), 
    FOREIGN KEY (victim_no) REFERENCES victim(victim_no) 
		  ON DELETE CASCADE ON UPDATE CASCADE
);


--13. Affects Table (Many-to-Many : crime - victim)
CREATE TABLE affects ( 
    victim_no VARCHAR(5), 
    fir_no VARCHAR(5), 
    PRIMARY KEY (victim_no, fir_no), 
    FOREIGN KEY (victim_no) REFERENCES victim(victim_no) 
		  ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (fir_no) REFERENCES crime(fir_no) 
		  ON DELETE CASCADE ON UPDATE CASCADE 
);


--14. Witness Table
CREATE TABLE witness (
    witness_no VARCHAR(5) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F', 'O')), 
    age INT CHECK (age > 0), 
    gov_id VARCHAR(15) UNIQUE,
    statement TEXT NOT NULL,
    base_address TEXT,
    city VARCHAR(15) NOT NULL,
    district VARCHAR(15) NOT NULL,
    state VARCHAR(15) NOT NULL
);


--15. Witness-Contact Table (Multivalue attribute of witness table)
CREATE TABLE witness_contact ( 
    witness_no VARCHAR(5), 
    contact_no VARCHAR(10), 
    PRIMARY KEY (witness_no, contact_no), 
    FOREIGN KEY (witness_no) REFERENCES witness(witness_no) 
		  ON DELETE CASCADE ON UPDATE CASCADE
);


--16. ObservedBy Table (Many-to-Many : crime - witness)
CREATE TABLE observed_by ( 
    witness_no VARCHAR(5), 
    fir_no VARCHAR(5), 
    PRIMARY KEY (witness_no, fir_no), 
    FOREIGN KEY (witness_no) REFERENCES witness(witness_no) 
		ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (fir_no) REFERENCES crime(fir_no) 
		ON DELETE CASCADE ON UPDATE CASCADE 
); 


--17. Suspect Table
CREATE TABLE suspect (
    suspect_no VARCHAR(5) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F', 'O')), 
    suspect_basis TEXT NOT NULL,
    age INT CHECK (age > 0), 
    relationship_with_victim VARCHAR(15),
    base_address TEXT,
    city VARCHAR(15) NOT NULL,
    district VARCHAR(15) NOT NULL,
    state VARCHAR(15) NOT NULL
);


--18. Suspect-Contact Table (Multivalue attribute of suspect table)
CREATE TABLE suspect_contact ( 
    suspect_no VARCHAR(5), 
    contact_no VARCHAR(10), 
    PRIMARY KEY (suspect_no, contact_no), 
    FOREIGN KEY (suspect_no) REFERENCES suspect(suspect_no) 
		ON DELETE CASCADE ON UPDATE CASCADE
);


--19. AssociateWith Table (Many-to-Many : crime - suspect)
CREATE TABLE associate_with ( 
    suspect_no VARCHAR(5), 
    fir_no VARCHAR(5), 
    PRIMARY KEY (suspect_no, fir_no), 
    FOREIGN KEY (suspect_no) REFERENCES suspect(suspect_no) 
		ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (fir_no) REFERENCES crime(fir_no) 
		ON DELETE CASCADE ON UPDATE CASCADE 
); 

