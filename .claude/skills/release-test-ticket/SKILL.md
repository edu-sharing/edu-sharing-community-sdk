---
name: release-test-ticket
description: Ermittelt die fachlichen Änderungen zwischen zwei Release-Ständen eines edu-sharing-Kundenprojekts (Deploy-Repo + BOM + Teilprojekte) und erstellt daraus ein Test-Ticket für den Tester. Nutze diesen Skill, wenn der User fragt "was hat sich seit dem letzten Release geändert", eine Testliste/Changelog für einen Tester braucht, ein Release-Test-Ticket in Jira anlegen will, oder Release-Notes zwischen zwei Versionen (z. B. zwei RC-Tags) zusammenfassen soll — auch wenn er nicht ausdrücklich "Skill" sagt.
---

# Release-Testliste für ein Kundenprojekt erstellen

Ein edu-sharing-Kundenprojekt ("Deploy"-Repo, z. B. `edu-sharing-projects-<kunde>`) zieht
seine Abhängigkeiten über eine BOM (`edu_sharing-community-bom`). Beim Release-Wechsel
(z. B. `11.0.0-RC8` → `11.0.0-RC12`) hat sich nicht nur das Deploy-Repo selbst geändert,
sondern über die BOM auch mehrere Teilprojekte (`repository`, `repository-*`,
`services-*`, `sdk`, ...), jedes mit eigener Versionsnummer und eigenem Änderungsumfang.

Ziel dieses Skills: aus den tatsächlichen Commits zwischen den beiden Release-Ständen eine
**für einen manuellen Tester verständliche, fachliche Testliste** ableiten und daraus ein
Ticket erzeugen — keine Commit-Historie, sondern konkrete Klickschritte pro Änderung.

## 0. Repo-Layout verstehen

Die Teilprojekte liegen normalerweise als **Geschwister-Checkouts im selben
übergeordneten Ordner** wie das Deploy-Repo (ein "Link"/Worktree-Setup), z. B.:

```
<parent>/
  bom/
  deploy/                  ← das Kundenprojekt, hier wird meist gearbeitet
  repository/
  repository-antivirus/
  repository-cluster/
  repository-elastic/
  repository-kafka/
  repository-mongo/
  repository-remote/
  repository-repackaged/
  repository-transform/
  sdk/
  services-connector/
  services-rendering/
  services-rendering2/     ← nicht immer vorhanden, siehe unten
```

Die Verzeichnisnamen entsprechen den Property-Namen aus der BOM (`bom.<name>.version`
→ Ordner `<name>`). **Prüfe das Layout am Anfang jedes Laufs neu** (`ls` im
übergeordneten Ordner) — verlasse dich nicht auf eine feste Liste.

**Wichtige Ausnahme:** `services-rendering2` (Rendering Service 2) ist in vielen
Umgebungen **kein** Geschwister-Checkout im selben Ordner, sondern liegt lokal woanders
oder muss erst geklont werden — das ist von Rechner zu Rechner unterschiedlich. **Frage
den User nach dem lokalen Pfad zu seinem `services-rendering2`-Checkout**, wenn er nicht
als Geschwisterordner existiert; nimm niemals einen zuvor in einer anderen Session
gesehenen Pfad als gegeben an. Das gilt allgemein: taucht ein Teilprojekt aus der
BOM-Versionsmatrix (Schritt 2) nicht als Geschwisterordner auf, frag nach, wo es liegt,
statt zu raten oder anzunehmen es existiere nicht.

## 1. Versionsspanne festlegen

Frage den User nach altem und neuem Release-Stand des Deploy-Repos (z. B. zwei Git-Tags
wie `11.0.0-RC8` und `11.0.0-RC12`), falls nicht bereits genannt.

## 2. BOM-Versionsmatrix ermitteln — die eigentliche Änderungsübersicht

Im `bom`-Checkout die `pom.xml` zwischen den beiden Tags des **Deploy-Repos** diffen
(die BOM-Version entspricht i.d.R. der Deploy-Projektversion, da
`bom.bom.version = ${project.version}`):

```bash
git -C <parent>/bom diff <alt>..<neu> -- pom.xml
```

Das Ergebnis ist eine Liste `bom.<teilprojekt>.version: <alt-version> → <neu-version>`
für jedes betroffene Teilprojekt — das ist die **maßgebliche Versionsmatrix**, nicht die
Deploy-`pom.xml` selbst (die referenziert nur `${project.version}`/`${bom.bom.version}`).

Für jedes Teilprojekt mit geänderter Version zusätzlich die Commit-Anzahl ermitteln, um
den Aufwand pro Repo abzuschätzen und die Analyse sinnvoll aufzuteilen:

```bash
git -C <pfad-zum-teilprojekt> rev-list --count <alt-version>..<neu-version>
```

Teilprojekte mit **nur** einer geänderten Versionszeile in der eigenen `pom.xml` und ohne
weitere Dateiänderungen (reine `bump: updated dependencies`-Commits) sind fürs Testen
meist irrelevant — das aber erst nach dem Diff bestätigen, nicht vorher annehmen.

## 3. Analyse parallelisieren (mehrere Agenten)

Nicht alles seriell in einem Kontext durcharbeiten — die Commit-Zahlen aus Schritt 2
schwanken stark (ein Repo kann 5 Commits haben, ein anderes 90+). Fasse die Analyse in
2–4 parallele `Explore`- bzw. `general-purpose`-Agenten zusammen, grob nach Umfang und
Zusammengehörigkeit gruppiert, z. B.:

- Ein Agent für das **mit Abstand größte Teilprojekt** (meist `repository`) allein.
- Ein Agent für **Rendering** (`services-rendering2` + `services-rendering` zusammen,
  da fachlich verwandt).
- Ein Agent für **Connector + kleinere Plugin-Repos** (`services-connector`,
  `repository-elastic`, `repository-antivirus`, `repository-cluster`,
  `repository-mongo`, `repository-kafka`, `repository-remote`,
  `repository-transform`) **plus das Deploy-Repo selbst** — das Deploy-Repo verdient
  dabei besondere Aufmerksamkeit, weil dort die kundenspezifischen Anpassungen stecken
  (Suchtemplates, Metadatensets, i18n, `client.config.xml`).

Jedem Agenten in etwa mitgeben:
- Exakte Repo-Pfade und Alt-/Neu-Tags.
- Nur lesend arbeiten (`git log --no-merges --format='%h|%ci|%s' <alt>..<neu>`,
  `git diff --stat`, `git show` für einzelne Commits).
- Reine `bump:`/CI-/Formatierungs-Commits von fachlichen Änderungen trennen.
- Pro fachlicher Änderung: Kurzbeschreibung, betroffener Bereich, und ein **konkreter
  Testschritt** (Klickpfad + erwartetes Ergebnis, kein "Suche testen").
- Risiko-/Regressionsbereiche explizit benennen.
- Migrations-/Deployment-relevante Änderungen (neue Queues, DB-Skripte, Indizes,
  geänderte Default-Konfiguration) gesondert kennzeichnen.

## 4. Umfang und Ziel mit dem User abstimmen, bevor die Liste geschrieben wird

Bevor der Ticket-Text final formuliert wird, per `AskUserQuestion` klären (sofern nicht
schon vom User vorgegeben):

1. **Zielformat** — Jira-Ticket, Markdown-Datei, Confluence-Seite, Artifact?
2. **Detailgrad** — rein fachlich für einen Tester (keine Commit-IDs, keine Repo-/
   Konfigurationsnamen) vs. technisch mit Referenzen, für einen technisch versierten
   Tester oder Entwickler?
3. **Umfang** — nur über die Oberfläche prüfbare Anwendungsfunktionen, oder auch
   Infrastruktur/Deployment (Queues, Cluster, Migrationsschritte)?
4. Bei Jira zusätzlich: **welches Projekt/Issue-Typ**, und **ein Sammelticket vs.
   Sub-Tasks** pro Testbereich.

Änderungen, die reine Versions-Bumps ohne fachliche Wirkung sind, explizit als solche
kennzeichnen ("keine funktionalen Änderungen, nur Versionsstand") statt sie wegzulassen
— das erspart dem Tester, dort selbst nachzuschauen.

## 5. Ticket-Entwurf schreiben

Struktur, die sich bewährt hat:

- **Muss geprüft werden** — kundenspezifische Anpassungen (Deploy-Repo) und
  Breaking-Change-Kandidaten zuerst, insbesondere Datenmigrationen ohne automatisches
  Update von Bestandsdaten (z. B. geänderte Wertebereiche in Metadatenfeldern).
- **Sollte geprüft werden** — neue Features und general-purpose Änderungen, optionale
  Module (H5P, OnlyOffice, Sodix, ...) klar als "nur falls im Einsatz" markieren.
- **Kurzcheck** — kosmetische/i18n-Änderungen sowie ein Rauchtest für Teilprojekte ohne
  fachliche Änderung.
- Am Ende offene Rückfragen an den Tester, wo eine Entscheidung von seinem Befund abhängt
  (z. B. "wie viele Bestandsobjekte sind betroffen?").

Vor dem Anlegen/Aktualisieren in Jira den fertigen Entwurf dem User zur Bestätigung
zeigen (Plan-Modus oder als Text) — nicht direkt ungefragt veröffentlichen.

## 6. Bekannte Einschränkung: Checklisten in Jira

Manche Jira-Instanzen rendern das Beschreibungsfeld noch über den klassischen
Wiki-Markup-Renderer (Server/Data-Center-Stil: `<h2><a name=...>`, `<b>` statt
`<strong>`). Dort werden weder Markdown-Checklisten (`- [ ]`) noch native ADF-`taskList`-
Knoten als anklickbare Checkbox dargestellt — beides landet als einfache Aufzählung. Das
lässt sich nicht über Formatierung umgehen. Prüfen, ob es sich um so eine Instanz
handelt, indem man die Beschreibung nach dem Schreiben mit `expand: renderedFields`
abruft und das HTML ansieht (`<ul><li>...` ohne `<input type="checkbox">` = klassischer
Renderer). Ist das der Fall, dem User das transparent machen, statt Checkboxen zu
versprechen — Alternativen sind Sub-Tasks pro Testbereich oder manuelles Nachtippen im
Jira-Editor durch den User selbst.
