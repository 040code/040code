---
layout:     post
title:      "GraphQL + Spring Boot"
subtitle:   "Queries, mutations and subscription in Java"
date:       2018-02-14
authors:     [niek]
header-img: "assets/2018-02-14-service-discovery/holstlaan-dommel.jpg"
tags: [graphql, spring, java]
---

### Introduction
Now GraphQL is not anymore that new kid on a block it would be nice if we can implement a service with a GraphQL interface. Spring boot is one of the well known frameworks to build your micro services in Java so time to asses how easy or hard it will be to implement a GraphQL service. In this post I will go beyond a too simple hello world example but I will be able to implement all requirements for a production ready service. I will showcase all major features in GraphQL.

GraphQL is API is based on three main concept. Query the backend for data using a graph based query. The query is in a JSON like style and the response is valid JSON. Mutation are the way to change data in the system based on flat input object. In this example we use mutation to add new information. Finally we have subscription to subscribe for changes and get notified once something is changed via a web socket.

### Java, Spring and GraphQL.
Before we start let's explore the possibilities we have for a Java Spring Boot implementation.
....

### Sample Model and API
Notes and authors


### Create a simple Note Service
```java
@Entity
public class Person {
    @Id @GeneratedValue
    private final Long id = null;

    @Column(unique = true)
    private String name;

    private String email;
}
```
```java
@Entity
public class Note {
    @Id @GeneratedValue
    private final Long id = null;

    private String note;

    private ZonedDateTime createdOn;

    @ManyToOne(fetch = FetchType.EAGER)
    private Person author;
}
```
```java
@Repository
public interface PersonRepository extends CrudRepository<Person, Long> {

    List<Person> findAll();
}

```
```java
@Repository
public interface NoteRepository extends CrudRepository<Note, Long> {

    List<Note> findAll();
}
```
```java

@Service
public interface NotesService {

    public Note save(Note note);

    public Optional<Note> findById(Long id);

    public List<Note> findAll();
}

```

So that is all to create a simple service with basic JPA (persistence) capacity. TIme to focus on adding GraphQL to our service.


### Implement a query
As base library we use `graphql-java-tools` this library requires a GraphQL schema to implment GrahpQL. The first step is to define a schema for our queries. The schema defines our GraphQL root, for now only the query. Next the queries we will implement and the types we use. We define two queries. The first one to look op a note and the second one to find all notes based on a filter. Next we define the types. As you can see a Note has a relation to a Person object. By querying for a note we can get immediatly the authors name for example.

```
schema {
    query: Query,
}

type Query {
    note(id: Long!): Note
    notes: [Note]
}

# Object to represent a note
type Note {
    id: ID!
    note: String
    createdOn : String
    author: Person
}

# Object to represent a note
type Person {
    id: ID!
    name: String
    email: String
}


```
Now we have a basic GraphQL schema. Time to connect the schema to the Note Service. GraphQL java tools expects for each query a resolver function. Therefore we need to implement `GraphQLQueryResolver` from graphql-tools.


```
@Component
public class Query implements GraphQLQueryResolver {

    private NotesService notesService;

    public Query(NotesService notesService) {
        this.notesService = notesService;
    }

    public Optional<Note> note(final Long id) {
        return notesService.findById(id);
    }

    public List<Note> notes() {
        return notesService.findAll();
    }
}
```

This is all we have to do to be able to handle the quries as specified in the schema. We can now start the the spring boot application and open http://locahost:8080/graphiql and query form some. We can now start the application and execute some queries, but since we have now way to add data, the result will always be empty.

Time to add functionality to add new notes to the application. In GraphQL you mutate data via a mutation. In the next step we add a mutation to the schema and update the code for executing the mutation.

In the schema add the mutation to the root of the schema and a list of supported mutation. In GraphQL you cannot use relation in mutation, only a flat object is allowed. For the new note we defin an input ojbect.

```

type Query {
    ...
    notes: [Note]
}

type Mutation {
    addNote(note: InputNote!, author: InputPerson!): Note
}

# Input type for the author of the note
input InputPerson {
    name: String!
    email: String
}

# Input type for a new Note
input InputNote {
    note: String!
}
```

Similar to implementing the query we have to implement an interface and declare methods for the mutation. Mutations have to be implemented in a class implementing the interface GraphQLMutationResolver. In this implementation we defined for the input objects converters to convert the GraphQL imput object to domain objects that can be consumed by the service.

```
@Component
public class Mutation implements GraphQLMutationResolver {

    public Note addNote(final InputNote note, final InputPerson author) {
        return notesService.save(InputNote.convert(note, author));
    }
}

```

At this moment we have implemented a minimal application where we caan add new notes an query for notes. So time to play around.



- Graphql Query
- Test

### Implement Mutation

### Implement Subscription


### Discuss
- Pagenation
- Relay spec
- Security
-
