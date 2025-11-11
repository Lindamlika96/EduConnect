-- seed_courses.sql
-- ===================================
-- Script de population initiale de la table course
-- ===================================

-- Suppression des anciens enregistrements (optionnelle)
DELETE FROM course;

-- Ajout de cours de base
INSERT INTO course (
  mentor_id, title, description_html, level, language, duration_minutes,
  pdf_path, thumbnail_path, rating_avg, rating_count, students_count,
  summary_text, created_at, updated_at
) VALUES
(1, 'Bases de données', '<p>Introduction au SQL, modèles relationnels et clés étrangères.</p>', 1, 0, 60,
 'assets/pdfs/sql.pdf', NULL, 4.3, 80, 210, NULL, strftime('%s','now')*1000, strftime('%s','now')*1000),

(2, 'Flutter – Démarrage', '<p>Créer votre première application mobile avec Flutter et Dart.</p>', 1, 0, 45,
 'assets/pdfs/flutter_basics.pdf', NULL, 4.5, 95, 300, NULL, strftime('%s','now')*1000, strftime('%s','now')*1000),

(3, 'Algo – Notions de base', '<p>Structures de contrôle, variables et fonctions.</p>', 1, 0, 40,
 'assets/pdfs/algo.pdf', NULL, 4.2, 60, 150, NULL, strftime('%s','now')*1000, strftime('%s','now')*1000),

(4, 'Réseaux – Concepts', '<p>Modèles OSI, TCP/IP et routage de base.</p>', 1, 0, 50,
 'assets/pdfs/networks.pdf', NULL, 4.1, 70, 190, NULL, strftime('%s','now')*1000, strftime('%s','now')*1000),

(5, 'IA – Introduction', '<p>Différences entre apprentissage automatique et apprentissage profond.</p>', 1, 0, 55,
 'assets/pdfs/ml_intro.pdf', NULL, 4.4, 110, 220, NULL, strftime('%s','now')*1000, strftime('%s','now')*1000);
